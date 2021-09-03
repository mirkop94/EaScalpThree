#property version "1.00"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>

int lotDigits; //initialized in OnInit
double tradeSize = 0.1;
int maxSlippage = 3; //adjusted in OnInit
double thisPoint;    //initialized in OnIni

double stopLoss = 50;
double takeProfit = 50;

int tradeTicketLong = 0;
int tradeTicketShort = 0;

int OnInit()
{
    /*This section will be useful if the EA is supposed to trade more instruments at once - atm not used
  for future implementation*/

    //initialize thisPoint
    thisPoint = Point();
    if (Digits() == 5 || Digits() == 3)
    {
        thisPoint *= 10;
        maxSlippage *= 10;
    }
    //initialize lotDigits
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    if (NormalizeDouble(lotStep, 3) == round(lotStep))
        lotDigits = 0;
    else if (NormalizeDouble(10 * lotStep, 3) == round(10 * lotStep))
        lotDigits = 1;
    else if (NormalizeDouble(100 * lotStep, 3) == round(100 * lotStep))
        lotDigits = 2;
    else
        lotDigits = 3;

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
    bool prevCandles;
    double comparedFirst;
    double comparedSecond;
    int i;

    bool isTradeOpened = OrdersTotal() > 0;

    for (i = 0; i < 3; i++)
    {
        comparedFirst = iClose(NULL, 0, i + 1);
        comparedSecond = iClose(NULL, 0, i + 2);
        prevCandles = prevCandles && comparedSecond < comparedFirst;
    }

    if (prevCandles == true && isTradeOpened == false)
    {

        tradeTicketLong = OrderSend(NULL,
                                    OP_BUY,
                                    tradeSize,
                                    Ask,
                                    maxSlippage,
                                    Bid - (stopLoss * Point()),
                                    Ask + (takeProfit * Point()),
                                    NULL,
                                    0,
                                    clrAzure);
    }
    else if (prevCandles == false && isTradeOpened == false)
    {

        tradeTicketShort = OrderSend(NULL,
                                     OP_SELL,
                                     tradeSize,
                                     Bid,
                                     maxSlippage,
                                     Ask + (stopLoss * Point()),
                                     Bid - (takeProfit * Point()),
                                     NULL,
                                     0,
                                     clrCrimson);
    }
}
