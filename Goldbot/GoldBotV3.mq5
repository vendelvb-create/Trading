//+------------------------------------------------------------------+
//|                                                   GoldBotV3.mq5 |
//|                    XAUUSD M30 - Bot V3                          |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>

CTrade trade;

//==================================================================
// INPUTS
//==================================================================

//--- General
input string           InpSymbol              = "XAUUSD";
input ENUM_TIMEFRAMES  InpTimeframe           = PERIOD_M30;
input ulong            InpMagicNumber         = 30001;

//--- Position sizing
input double           InpLots                = 0.01;
input int              InpMaxPositions       = 2;

//--- EMA signal
input int              InpFastEMA             = 20;
input int              InpSlowEMA             = 50;

//--- Trend filter
input bool             InpUseTrendFilter      = true;
input int              InpTrendEMA            = 200;

//--- Market structure
input bool             InpUseStructureFilter  = true;
input int              InpStructureLookback   = 10;

//--- Momentum / RSI
input bool             InpUseMomentumFilter   = true;
input int              InpRSIPeriod           = 14;
input double           InpBuyRSIMin           = 50.0;
input double           InpBuyRSIMax           = 75.0;
input double           InpSellRSIMin          = 25.0;
input double           InpSellRSIMax          = 50.0;

//--- ATR / volatility
input bool             InpUseATRFilter        = true;
input int              InpATRPeriod           = 14;
input double           InpMinATR              = 2.0;
input double           InpMaxATR              = 100.0;

//--- Stop loss / take profit
input double           InpATRStopMultiplier   = 1.5;
input double           InpRiskReward          = 2.0;

//--- Risk protection
input bool             InpUseDailyLossLimit   = true;
input double           InpMaxDailyLossPercent = 3.0;

//--- Cooldown
input bool             InpUseCooldown         = true;
input int              InpCooldownBars        = 2;

//--- Trading controls
input bool             InpAllowBuy            = true;
input bool             InpAllowSell           = true;

//==================================================================
// INDICATOR HANDLES
//==================================================================

int fastEMAHandle  = INVALID_HANDLE;
int slowEMAHandle  = INVALID_HANDLE;
int trendEMAHandle = INVALID_HANDLE;
int rsiHandle      = INVALID_HANDLE;
int atrHandle      = INVALID_HANDLE;

//==================================================================
// GLOBAL VARIABLES
//==================================================================

datetime lastBarTime   = 0;
datetime lastTradeTime = 0;

double dayStartEquity  = 0.0;
int    currentDay      = -1;
bool   barStateReady   = false;

string stateScopeKey   = "";
string barStateKey     = "";
string instanceLockKey = "";
double instanceToken   = 0.0;
bool   instanceLockHeld = false;

//==================================================================
// INITIALIZATION
//==================================================================

int OnInit()
{
   ENUM_ACCOUNT_MARGIN_MODE marginMode =
      (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(
         ACCOUNT_MARGIN_MODE
      );

   if(marginMode != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print(
         "GoldBotV3: INIT FAILED - account mode ",
         EnumToString(marginMode),
         " uses netted symbol positions; GoldBot ownership cannot be safely attributed."
      );

      return INIT_FAILED;
   }

   if(!InitializeStateKeys() ||
      !AcquireInstanceLock())
   {
      return INIT_FAILED;
   }

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(50);

   //--- EMA handles
   fastEMAHandle = iMA(
      InpSymbol,
      InpTimeframe,
      InpFastEMA,
      0,
      MODE_EMA,
      PRICE_CLOSE
   );

   slowEMAHandle = iMA(
      InpSymbol,
      InpTimeframe,
      InpSlowEMA,
      0,
      MODE_EMA,
      PRICE_CLOSE
   );

   trendEMAHandle = iMA(
      InpSymbol,
      InpTimeframe,
      InpTrendEMA,
      0,
      MODE_EMA,
      PRICE_CLOSE
   );

   //--- RSI
   rsiHandle = iRSI(
      InpSymbol,
      InpTimeframe,
      InpRSIPeriod,
      PRICE_CLOSE
   );

   //--- ATR
   atrHandle = iATR(
      InpSymbol,
      InpTimeframe,
      InpATRPeriod
   );

   //--- Validate handles
   if(fastEMAHandle == INVALID_HANDLE ||
      slowEMAHandle == INVALID_HANDLE ||
      trendEMAHandle == INVALID_HANDLE ||
      rsiHandle == INVALID_HANDLE ||
      atrHandle == INVALID_HANDLE)
   {
      Print("GoldBotV3: Failed to create indicator handles.");
      ReleaseInstanceLock();
      return INIT_FAILED;
   }

   int tradingDay = -1;

   if(!GetTradingDayIdentity(TimeCurrent(), tradingDay) ||
      !LoadOrCreateDailyBaseline(tradingDay) ||
      !RestoreLastTradeTime())
   {
      Print("GoldBotV3: INIT FAILED - restart-safe state could not be established.");
      ReleaseInstanceLock();
      return INIT_FAILED;
   }

   datetime currentBarTime = iTime(
      InpSymbol,
      InpTimeframe,
      0
   );

   if(currentBarTime > 0 &&
      !InitializeBarState(currentBarTime))
   {
      Print("GoldBotV3: INIT FAILED - processed-bar state could not be established.");
      ReleaseInstanceLock();
      return INIT_FAILED;
   }

   Print("==============================================");
   Print("GoldBotV3 initialized.");
   Print("Symbol: ", InpSymbol);
   Print("Timeframe: ", EnumToString(InpTimeframe));
   Print("Fast EMA: ", InpFastEMA);
   Print("Slow EMA: ", InpSlowEMA);
   Print("Trend EMA: ", InpTrendEMA);
   Print("Lots: ", InpLots);
   Print("Max positions: ", InpMaxPositions);
   Print("==============================================");

   return INIT_SUCCEEDED;
}

//==================================================================
// DEINITIALIZATION
//==================================================================

void OnDeinit(const int reason)
{
   if(fastEMAHandle != INVALID_HANDLE)
      IndicatorRelease(fastEMAHandle);

   if(slowEMAHandle != INVALID_HANDLE)
      IndicatorRelease(slowEMAHandle);

   if(trendEMAHandle != INVALID_HANDLE)
      IndicatorRelease(trendEMAHandle);

   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);

   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);

   ReleaseInstanceLock();
}

//==================================================================
// MAIN TICK FUNCTION
//==================================================================

void OnTick()
{
   if(!ResetDailyStatsIfNeeded())
   {
      Print("GoldBotV3: Trading blocked - daily state is unavailable.");
      return;
   }

   //--- Only make decisions on a new M30 candle
   datetime currentBarTime = iTime(
      InpSymbol,
      InpTimeframe,
      0
   );

   if(currentBarTime == 0)
      return;

   if(!barStateReady &&
      !InitializeBarState(currentBarTime))
   {
      Print("GoldBotV3: Trading blocked - processed-bar state is unavailable.");
      return;
   }

   if(currentBarTime <= lastBarTime)
      return;

   //================================================================
   // INDICATOR ARRAYS
   //================================================================

   double fastEMA[3];
   double slowEMA[3];
   double trendEMA[3];
   double rsi[3];
   double atr[3];

   // IMPORTANT:
   // Do NOT use ArraySetAsSeries() here.
   //
   // CopyBuffer() places the requested data in chronological
   // physical-memory order:
   //
   // [0] = shift 2
   // [1] = shift 1 (last completed candle)
   // [2] = shift 0 (current candle)
   //
   // This lets us use [1] for the last completed candle.

   if(CopyBuffer(fastEMAHandle, 0, 0, 3, fastEMA) < 3)
      return;

   if(CopyBuffer(slowEMAHandle, 0, 0, 3, slowEMA) < 3)
      return;

   if(CopyBuffer(trendEMAHandle, 0, 0, 3, trendEMA) < 3)
      return;

   if(CopyBuffer(rsiHandle, 0, 0, 3, rsi) < 3)
      return;

   if(CopyBuffer(atrHandle, 0, 0, 3, atr) < 3)
      return;

   //================================================================
   // LAST COMPLETED CANDLE
   //================================================================

   double close1 = iClose(
      InpSymbol,
      InpTimeframe,
      1
   );

   if(close1 <= 0)
      return;

   if(!PersistProcessedBar(currentBarTime))
   {
      Print("GoldBotV3: Trading blocked - current bar could not be persisted.");
      return;
   }

   lastBarTime = currentBarTime;

   //--- Daily loss protection
   if(IsDailyLossLimitReached())
   {
      Print("GoldBotV3: Daily loss limit reached.");
      return;
   }

   //--- Maximum positions
   if(CountMyPositions() >= InpMaxPositions)
   {
      Print("GoldBotV3: Maximum positions reached.");
      return;
   }

   //================================================================
   // EMA CROSS SIGNAL
   //================================================================

   bool buySignal =
      fastEMA[0] <= slowEMA[0] &&
      fastEMA[1] >  slowEMA[1];

   bool sellSignal =
      fastEMA[0] >= slowEMA[0] &&
      fastEMA[1] <  slowEMA[1];

   //================================================================
   // BUY
   //================================================================

   if(buySignal && InpAllowBuy)
   {
      Print("GoldBotV3: BUY EMA signal detected.");

      if(PassBuyFilters(
         close1,
         trendEMA[1],
         rsi[1],
         atr[1]))
      {
         OpenBuy(atr[1]);
      }
      else
      {
         Print("GoldBotV3: BUY rejected by filters.");
      }
   }

   //================================================================
   // SELL
   //================================================================

   if(sellSignal && InpAllowSell)
   {
      Print("GoldBotV3: SELL EMA signal detected.");

      if(PassSellFilters(
         close1,
         trendEMA[1],
         rsi[1],
         atr[1]))
      {
         OpenSell(atr[1]);
      }
      else
      {
         Print("GoldBotV3: SELL rejected by filters.");
      }
   }
}

//==================================================================
// TRADE TRANSACTION CONFIRMATION
//==================================================================

void OnTradeTransaction(
   const MqlTradeTransaction &trans,
   const MqlTradeRequest &request,
   const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD ||
      trans.deal == 0)
   {
      return;
   }

   datetime dealTime = 0;

   if(!GetOwnedEntryDeal(
      trans.deal,
      true,
      dealTime))
   {
      return;
   }

   if(dealTime > lastTradeTime)
   {
      lastTradeTime = dealTime;

      Print(
         "GoldBotV3: CONFIRMED DEAL transaction. Deal=",
         trans.deal,
         " Time=",
         TimeToString(dealTime, TIME_DATE | TIME_SECONDS)
      );
   }
}

//==================================================================
// BUY FILTERS
//==================================================================

bool PassBuyFilters(
   double closePrice,
   double trendEMA,
   double rsi,
   double atr)
{
   //--- Trend filter
   if(InpUseTrendFilter)
   {
      if(closePrice <= trendEMA)
      {
         Print("BUY rejected: price below trend EMA.");
         return false;
      }
   }

   //--- Structure filter
   if(InpUseStructureFilter)
   {
      if(!BuyStructureOK())
      {
         Print("BUY rejected: market structure.");
         return false;
      }
   }

   //--- Momentum filter
   if(InpUseMomentumFilter)
   {
      if(rsi < InpBuyRSIMin ||
         rsi > InpBuyRSIMax)
      {
         Print(
            "BUY rejected: RSI = ",
            DoubleToString(rsi, 2)
         );

         return false;
      }
   }

   //--- ATR filter
   if(InpUseATRFilter)
   {
      if(atr < InpMinATR ||
         atr > InpMaxATR)
      {
         Print(
            "BUY rejected: ATR = ",
            DoubleToString(atr, 2)
         );

         return false;
      }
   }

   //--- Cooldown
   if(InpUseCooldown)
   {
      if(!CooldownOK())
         return false;
   }

   return true;
}

//==================================================================
// SELL FILTERS
//==================================================================

bool PassSellFilters(
   double closePrice,
   double trendEMA,
   double rsi,
   double atr)
{
   //--- Trend filter
   if(InpUseTrendFilter)
   {
      if(closePrice >= trendEMA)
      {
         Print("SELL rejected: price above trend EMA.");
         return false;
      }
   }

   //--- Structure filter
   if(InpUseStructureFilter)
   {
      if(!SellStructureOK())
      {
         Print("SELL rejected: market structure.");
         return false;
      }
   }

   //--- Momentum filter
   if(InpUseMomentumFilter)
   {
      if(rsi < InpSellRSIMin ||
         rsi > InpSellRSIMax)
      {
         Print(
            "SELL rejected: RSI = ",
            DoubleToString(rsi, 2)
         );

         return false;
      }
   }

   //--- ATR filter
   if(InpUseATRFilter)
   {
      if(atr < InpMinATR ||
         atr > InpMaxATR)
      {
         Print(
            "SELL rejected: ATR = ",
            DoubleToString(atr, 2)
         );

         return false;
      }
   }

   //--- Cooldown
   if(InpUseCooldown)
   {
      if(!CooldownOK())
         return false;
   }

   return true;
}

//==================================================================
// BUY MARKET STRUCTURE
//==================================================================

bool BuyStructureOK()
{
   int highestShift = iHighest(
      InpSymbol,
      InpTimeframe,
      MODE_HIGH,
      InpStructureLookback,
      2
   );

   if(highestShift < 0)
      return false;

   double previousHigh = iHigh(
      InpSymbol,
      InpTimeframe,
      highestShift
   );

   double close1 = iClose(
      InpSymbol,
      InpTimeframe,
      1
   );

   if(close1 > previousHigh)
      return true;

   return false;
}

//==================================================================
// SELL MARKET STRUCTURE
//==================================================================

bool SellStructureOK()
{
   int lowestShift = iLowest(
      InpSymbol,
      InpTimeframe,
      MODE_LOW,
      InpStructureLookback,
      2
   );

   if(lowestShift < 0)
      return false;

   double previousLow = iLow(
      InpSymbol,
      InpTimeframe,
      lowestShift
   );

   double close1 = iClose(
      InpSymbol,
      InpTimeframe,
      1
   );

   if(close1 < previousLow)
      return true;

   return false;
}

//==================================================================
// OPEN BUY
//==================================================================

void OpenBuy(double atr)
{
   double ask = SymbolInfoDouble(
      InpSymbol,
      SYMBOL_ASK
   );

   if(ask <= 0)
      return;

   double slDistance =
      atr * InpATRStopMultiplier;

   if(slDistance <= 0)
      return;

   double tpDistance =
      slDistance * InpRiskReward;

   double sl = ask - slDistance;
   double tp = ask + tpDistance;

   sl = NormalizePrice(sl);
   tp = NormalizePrice(tp);

   if(!ValidateStops(
      ORDER_TYPE_BUY,
      ask,
      sl,
      tp))
   {
      Print("GoldBotV3: Invalid BUY stops.");
      return;
   }

   Print(
      "GoldBotV3: Opening BUY | Lots=",
      DoubleToString(InpLots, 2),
      " SL=",
      DoubleToString(sl, _Digits),
      " TP=",
      DoubleToString(tp, _Digits)
   );

   ResetLastError();

   bool requestAccepted = trade.Buy(
      InpLots,
      InpSymbol,
      0.0,
      sl,
      tp,
      "GoldBotV3 BUY"
   );

   VerifyTradeResult("BUY", requestAccepted);
}

//==================================================================
// OPEN SELL
//==================================================================

void OpenSell(double atr)
{
   double bid = SymbolInfoDouble(
      InpSymbol,
      SYMBOL_BID
   );

   if(bid <= 0)
      return;

   double slDistance =
      atr * InpATRStopMultiplier;

   if(slDistance <= 0)
      return;

   double tpDistance =
      slDistance * InpRiskReward;

   double sl = bid + slDistance;
   double tp = bid - tpDistance;

   sl = NormalizePrice(sl);
   tp = NormalizePrice(tp);

   if(!ValidateStops(
      ORDER_TYPE_SELL,
      bid,
      sl,
      tp))
   {
      Print("GoldBotV3: Invalid SELL stops.");
      return;
   }

   Print(
      "GoldBotV3: Opening SELL | Lots=",
      DoubleToString(InpLots, 2),
      " SL=",
      DoubleToString(sl, _Digits),
      " TP=",
      DoubleToString(tp, _Digits)
   );

   ResetLastError();

   bool requestAccepted = trade.Sell(
      InpLots,
      InpSymbol,
      0.0,
      sl,
      tp,
      "GoldBotV3 SELL"
   );

   VerifyTradeResult("SELL", requestAccepted);
}

//==================================================================
// COUNT OUR POSITIONS
//==================================================================

int CountMyPositions()
{
   int count = 0;

   for(int i = PositionsTotal() - 1;
       i >= 0;
       i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      string symbol =
         PositionGetString(POSITION_SYMBOL);

      long magic =
         PositionGetInteger(POSITION_MAGIC);

      if(symbol == InpSymbol &&
         magic == (long)InpMagicNumber)
      {
         count++;
      }
   }

   return count;
}

//==================================================================
// TRADE RESULT / DEAL VERIFICATION
//==================================================================

bool VerifyTradeResult(
   string side,
   bool requestAccepted)
{
   uint retcode = trade.ResultRetcode();
   ulong dealTicket = trade.ResultDeal();
   ulong orderTicket = trade.ResultOrder();

   if(!requestAccepted)
   {
      Print(
         "GoldBotV3: ",
         side,
         " LOCAL REQUEST FAILURE. Retcode=",
         retcode,
         " Description=",
         trade.ResultRetcodeDescription(),
         " LastError=",
         GetLastError()
      );

      return false;
   }

   if(retcode == TRADE_RETCODE_DONE ||
      retcode == TRADE_RETCODE_DONE_PARTIAL)
   {
      datetime dealTime = 0;

      if(dealTicket == 0 ||
         !GetOwnedEntryDeal(
            dealTicket,
            true,
            dealTime))
      {
         Print(
            "GoldBotV3: ",
            side,
            " AMBIGUOUS SERVER RESULT. Retcode=",
            retcode,
            " Description=",
            trade.ResultRetcodeDescription(),
            " Order=",
            orderTicket,
            " Deal=",
            dealTicket,
            ". Execution could not be verified; cooldown not started."
         );

         return false;
      }

      if(dealTime > lastTradeTime)
         lastTradeTime = dealTime;

      Print(
         "GoldBotV3: ",
         side,
         retcode == TRADE_RETCODE_DONE_PARTIAL
            ? " CONFIRMED PARTIAL EXECUTION."
            : " CONFIRMED EXECUTION.",
         " Retcode=",
         retcode,
         " Order=",
         orderTicket,
         " Deal=",
         dealTicket
      );

      return true;
   }

   if(retcode == TRADE_RETCODE_PLACED)
   {
      Print(
         "GoldBotV3: ",
         side,
         " AMBIGUOUS SERVER RESULT. Order accepted/placed but no execution is confirmed. Retcode=",
         retcode,
         " Order=",
         orderTicket,
         ". Cooldown awaits an owned entry deal transaction."
      );

      return false;
   }

   Print(
      "GoldBotV3: ",
      side,
      " SERVER EXECUTION FAILURE. Retcode=",
      retcode,
      " Description=",
      trade.ResultRetcodeDescription(),
      " Order=",
      orderTicket,
      " Deal=",
      dealTicket
   );

   return false;
}

bool GetOwnedEntryDeal(
   ulong dealTicket,
   bool selectDeal,
   datetime &dealTime)
{
   dealTime = 0;

   if(dealTicket == 0)
      return false;

   if(selectDeal &&
      !HistoryDealSelect(dealTicket))
   {
      return false;
   }

   string symbol =
      HistoryDealGetString(
         dealTicket,
         DEAL_SYMBOL
      );

   long magic =
      HistoryDealGetInteger(
         dealTicket,
         DEAL_MAGIC
      );

   ENUM_DEAL_TYPE dealType =
      (ENUM_DEAL_TYPE)HistoryDealGetInteger(
         dealTicket,
         DEAL_TYPE
      );

   ENUM_DEAL_ENTRY dealEntry =
      (ENUM_DEAL_ENTRY)HistoryDealGetInteger(
         dealTicket,
         DEAL_ENTRY
      );

   if(symbol != InpSymbol ||
      magic != (long)InpMagicNumber ||
      (dealType != DEAL_TYPE_BUY &&
       dealType != DEAL_TYPE_SELL) ||
      (dealEntry != DEAL_ENTRY_IN &&
       dealEntry != DEAL_ENTRY_INOUT))
   {
      return false;
   }

   dealTime =
      (datetime)HistoryDealGetInteger(
         dealTicket,
         DEAL_TIME
      );

   return dealTime > 0;
}

bool RestoreLastTradeTime()
{
   datetime serverTime = TimeCurrent();

   if(serverTime <= 0)
   {
      Print("GoldBotV3: Cannot restore cooldown - invalid server time.");
      return false;
   }

   ResetLastError();

   if(!HistorySelect(0, serverTime))
   {
      Print(
         "GoldBotV3: Cannot restore cooldown from deal history. Error=",
         GetLastError()
      );

      return false;
   }

   int totalDeals = HistoryDealsTotal();

   for(int i = totalDeals - 1;
       i >= 0;
       i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      datetime dealTime = 0;

      if(GetOwnedEntryDeal(
         dealTicket,
         false,
         dealTime))
      {
         lastTradeTime = dealTime;

         Print(
            "GoldBotV3: Restored last confirmed trade. Deal=",
            dealTicket,
            " Time=",
            TimeToString(dealTime, TIME_DATE | TIME_SECONDS)
         );

         return true;
      }
   }

   lastTradeTime = 0;
   Print("GoldBotV3: No prior owned entry deal found for cooldown recovery.");
   return true;
}

//==================================================================
// RESTART-SAFE STATE / INSTANCE OWNERSHIP
//==================================================================

ulong HashStateValue(string value)
{
   ulong hash = 14695981039346656037;

   for(int i = 0;
       i < StringLen(value);
       i++)
   {
      hash ^= (ulong)StringGetCharacter(value, i);
      hash *= 1099511628211;
   }

   return hash;
}

bool InitializeStateKeys()
{
   long accountLogin =
      AccountInfoInteger(ACCOUNT_LOGIN);

   string accountServer =
      AccountInfoString(ACCOUNT_SERVER);

   if(accountLogin <= 0 ||
      accountServer == "" ||
      InpSymbol == "")
   {
      Print("GoldBotV3: Cannot create restart-safe state scope.");
      return false;
   }

   string scope = StringFormat(
      "%s|%I64d|%s|%I64u",
      accountServer,
      accountLogin,
      InpSymbol,
      InpMagicNumber
   );

   stateScopeKey = StringFormat(
      "%I64u",
      HashStateValue(scope)
   );

   barStateKey = StringFormat(
      "GB3B.%s.%d",
      stateScopeKey,
      (int)InpTimeframe
   );

   instanceLockKey =
      "GB3L." + stateScopeKey;

   if(StringLen(barStateKey) > 63 ||
      StringLen(instanceLockKey) > 63)
   {
      Print("GoldBotV3: Restart-safe state key exceeds terminal limit.");
      return false;
   }

   return true;
}

bool AcquireInstanceLock()
{
   if(!GlobalVariableCheck(instanceLockKey))
   {
      ResetLastError();

      if(!GlobalVariableTemp(instanceLockKey))
      {
         Print(
            "GoldBotV3: Cannot create instance lock. Error=",
            GetLastError()
         );

         return false;
      }
   }

   string tokenSource = StringFormat(
      "%I64d|%I64u",
      ChartID(),
      GetMicrosecondCount()
   );

   ulong tokenValue =
      HashStateValue(tokenSource)
      % 9007199254740991;

   if(tokenValue == 0)
      tokenValue = 1;

   instanceToken = (double)tokenValue;
   ResetLastError();

   if(!GlobalVariableSetOnCondition(
      instanceLockKey,
      instanceToken,
      0.0))
   {
      Print(
         "GoldBotV3: INIT FAILED - another active instance owns account/symbol/Magic scope. Lock=",
         instanceLockKey
      );

      return false;
   }

   instanceLockHeld = true;
   return true;
}

void ReleaseInstanceLock()
{
   if(!instanceLockHeld)
      return;

   ResetLastError();

   if(!GlobalVariableSetOnCondition(
      instanceLockKey,
      0.0,
      instanceToken))
   {
      Print(
         "GoldBotV3: Failed to release instance lock. Error=",
         GetLastError()
      );
   }

   instanceLockHeld = false;
}

bool PersistProcessedBar(datetime barTime)
{
   ResetLastError();

   if(GlobalVariableSet(
      barStateKey,
      (double)barTime) == 0)
   {
      Print(
         "GoldBotV3: Failed to persist processed bar. Error=",
         GetLastError()
      );

      return false;
   }

   GlobalVariablesFlush();
   return true;
}

bool InitializeBarState(datetime currentBarTime)
{
   if(currentBarTime <= 0)
      return false;

   if(GlobalVariableCheck(barStateKey))
   {
      double storedBar = 0.0;
      ResetLastError();

      if(!GlobalVariableGet(
         barStateKey,
         storedBar))
      {
         Print(
            "GoldBotV3: Failed to restore processed bar. Error=",
            GetLastError()
         );

         return false;
      }

      if(!MathIsValidNumber(storedBar) ||
         storedBar <= 0.0 ||
         storedBar != MathFloor(storedBar) ||
         storedBar > (double)currentBarTime)
      {
         Print("GoldBotV3: Invalid persisted processed-bar state; trading disabled.");
         return false;
      }

      lastBarTime = (datetime)storedBar;
      barStateReady = true;

      Print(
         "GoldBotV3: Restored last processed bar: ",
         TimeToString(lastBarTime, TIME_DATE | TIME_MINUTES)
      );

      return true;
   }

   if(!PersistProcessedBar(currentBarTime))
      return false;

   lastBarTime = currentBarTime;
   barStateReady = true;

   Print(
      "GoldBotV3: Initialized processed-bar state at ",
      TimeToString(lastBarTime, TIME_DATE | TIME_MINUTES),
      "; current bar intentionally skipped."
   );

   return true;
}

//==================================================================
// COOLDOWN
//==================================================================

bool CooldownOK()
{
   if(lastTradeTime == 0)
      return true;

   int barsPassed = iBarShift(
      InpSymbol,
      InpTimeframe,
      lastTradeTime,
      false
   );

   if(barsPassed < 0)
   {
      Print("GoldBotV3: Cooldown state unavailable; trading blocked safely.");
      return false;
   }

   if(barsPassed < InpCooldownBars)
   {
      Print(
         "GoldBotV3: Cooldown active. Bars passed=",
         barsPassed
      );

      return false;
   }

   return true;
}

//==================================================================
// DAILY RESET
//==================================================================

bool GetTradingDayIdentity(
   datetime serverTime,
   int &tradingDay)
{
   MqlDateTime dt;

   if(serverTime <= 0 ||
      !TimeToStruct(serverTime, dt) ||
      dt.year < 1970 ||
      dt.mon < 1 ||
      dt.mon > 12 ||
      dt.day < 1 ||
      dt.day > 31)
   {
      tradingDay = -1;
      return false;
   }

   tradingDay =
      dt.year * 10000 +
      dt.mon * 100 +
      dt.day;

   return true;
}

bool LoadOrCreateDailyBaseline(int tradingDay)
{
   string dailyStateKey = StringFormat(
      "GB3D.%s.%d",
      stateScopeKey,
      tradingDay
   );

   if(StringLen(dailyStateKey) > 63)
   {
      Print("GoldBotV3: Daily state key exceeds terminal limit.");
      return false;
   }

   if(GlobalVariableCheck(dailyStateKey))
   {
      double storedEquity = 0.0;
      ResetLastError();

      if(!GlobalVariableGet(
         dailyStateKey,
         storedEquity))
      {
         Print(
            "GoldBotV3: Failed to restore daily baseline. Error=",
            GetLastError()
         );

         return false;
      }

      if(!MathIsValidNumber(storedEquity) ||
         storedEquity <= 0.0)
      {
         Print("GoldBotV3: Invalid persisted daily baseline; trading disabled.");
         return false;
      }

      dayStartEquity = storedEquity;
      currentDay = tradingDay;

      Print(
         "GoldBotV3: Restored daily baseline. TradingDay=",
         currentDay,
         " Equity=",
         DoubleToString(dayStartEquity, 2)
      );

      return true;
   }

   double currentEquity =
      AccountInfoDouble(ACCOUNT_EQUITY);

   if(!MathIsValidNumber(currentEquity) ||
      currentEquity <= 0.0)
   {
      Print("GoldBotV3: Cannot establish daily baseline from current equity.");
      return false;
   }

   ResetLastError();

   if(GlobalVariableSet(
      dailyStateKey,
      currentEquity) == 0)
   {
      Print(
         "GoldBotV3: Failed to persist daily baseline. Error=",
         GetLastError()
      );

      return false;
   }

   GlobalVariablesFlush();

   dayStartEquity = currentEquity;
   currentDay = tradingDay;

   Print(
      "GoldBotV3: Created daily baseline. TradingDay=",
      currentDay,
      " Equity=",
      DoubleToString(dayStartEquity, 2)
   );

   return true;
}

bool ResetDailyStatsIfNeeded()
{
   int tradingDay = -1;

   if(!GetTradingDayIdentity(
      TimeCurrent(),
      tradingDay))
   {
      Print("GoldBotV3: Cannot determine complete server trading-day identity.");
      return false;
   }

   if(currentDay == tradingDay)
      return true;

   return LoadOrCreateDailyBaseline(tradingDay);
}

//==================================================================
// DAILY LOSS LIMIT
//==================================================================

bool IsDailyLossLimitReached()
{
   if(!InpUseDailyLossLimit)
      return false;

   if(dayStartEquity <= 0)
      return true;

   double equity =
      AccountInfoDouble(ACCOUNT_EQUITY);

   if(!MathIsValidNumber(equity) ||
      equity <= 0.0)
   {
      Print("GoldBotV3: Current equity unavailable; daily-loss protection blocks trading.");
      return true;
   }

   double lossPercent =
      ((dayStartEquity - equity)
      / dayStartEquity) * 100.0;

   if(lossPercent >= InpMaxDailyLossPercent)
      return true;

   return false;
}

//==================================================================
// PRICE NORMALIZATION
//==================================================================

double NormalizePrice(double price)
{
   double tickSize =
      SymbolInfoDouble(
         InpSymbol,
         SYMBOL_TRADE_TICK_SIZE
      );

   if(tickSize <= 0)
      return NormalizeDouble(price, _Digits);

   price =
      MathRound(price / tickSize)
      * tickSize;

   return NormalizeDouble(price, _Digits);
}

//==================================================================
// STOP VALIDATION
//==================================================================

bool ValidateStops(
   ENUM_ORDER_TYPE orderType,
   double entry,
   double sl,
   double tp)
{
   long stopsLevel =
      SymbolInfoInteger(
         InpSymbol,
         SYMBOL_TRADE_STOPS_LEVEL
      );

   double point =
      SymbolInfoDouble(
         InpSymbol,
         SYMBOL_POINT
      );

   double minDistance =
      stopsLevel * point;

   if(orderType == ORDER_TYPE_BUY)
   {
      if(sl >= entry)
         return false;

      if(tp <= entry)
         return false;

      if(minDistance > 0)
      {
         if((entry - sl) < minDistance)
            return false;

         if((tp - entry) < minDistance)
            return false;
      }
   }

   if(orderType == ORDER_TYPE_SELL)
   {
      if(sl <= entry)
         return false;

      if(tp >= entry)
         return false;

      if(minDistance > 0)
      {
         if((sl - entry) < minDistance)
            return false;

         if((entry - tp) < minDistance)
            return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| END OF GOLD BOT V3                                               |
//+------------------------------------------------------------------+

