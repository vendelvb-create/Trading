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

double dayStartEquity = 0.0;
int    currentDay     = -1;

//==================================================================
// INITIALIZATION
//==================================================================

int OnInit()
{
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
      return INIT_FAILED;
   }

   //--- Daily equity baseline
   dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   currentDay = dt.day;

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
}

//==================================================================
// MAIN TICK FUNCTION
//==================================================================

void OnTick()
{
   ResetDailyStatsIfNeeded();

   //--- Only make decisions on a new M30 candle
   datetime currentBarTime = iTime(
      InpSymbol,
      InpTimeframe,
      0
   );

   if(currentBarTime == 0)
      return;

   if(currentBarTime == lastBarTime)
      return;

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

   if(trade.Buy(
      InpLots,
      InpSymbol,
      0.0,
      sl,
      tp,
      "GoldBotV3 BUY"))
   {
      lastTradeTime = TimeCurrent();

      Print(
         "GoldBotV3: BUY opened. Ticket=",
         trade.ResultOrder()
      );
   }
   else
   {
      Print(
         "GoldBotV3: BUY failed. Error=",
         trade.ResultRetcode(),
         " ",
         trade.ResultRetcodeDescription()
      );
   }
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

   if(trade.Sell(
      InpLots,
      InpSymbol,
      0.0,
      sl,
      tp,
      "GoldBotV3 SELL"))
   {
      lastTradeTime = TimeCurrent();

      Print(
         "GoldBotV3: SELL opened. Ticket=",
         trade.ResultOrder()
      );
   }
   else
   {
      Print(
         "GoldBotV3: SELL failed. Error=",
         trade.ResultRetcode(),
         " ",
         trade.ResultRetcodeDescription()
      );
   }
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
      return true;

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

void ResetDailyStatsIfNeeded()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(currentDay != dt.day)
   {
      currentDay = dt.day;

      dayStartEquity =
         AccountInfoDouble(ACCOUNT_EQUITY);

      Print(
         "GoldBotV3: New trading day. Starting equity=",
         DoubleToString(dayStartEquity, 2)
      );
   }
}

//==================================================================
// DAILY LOSS LIMIT
//==================================================================

bool IsDailyLossLimitReached()
{
   if(!InpUseDailyLossLimit)
      return false;

   if(dayStartEquity <= 0)
      return false;

   double equity =
      AccountInfoDouble(ACCOUNT_EQUITY);

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