//+------------------------------------------------------------------+
//|                                               LastClosedBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\OrderManager.mqh>
#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LastClosedBase : public AbstractSignal
  {
private:
   double            _skew;
protected:
   virtual PriceRange CalculateRange(string symbol,int shift,double midPrice);
   virtual void      SetBuySignal(string symbol,int shift,MqlTick &tick);
   virtual void      SetSellSignal(string symbol,int shift,MqlTick &tick);
   void              SetSellExits(string symbol,int shift,MqlTick &tick);
   void              SetBuyExits(string symbol,int shift,MqlTick &tick);
   void              SetExits(string symbol,int shift,MqlTick &tick);
   int               LastClosedBase::GetLastClosedTicketNumber(string symbol);

public:
                     LastClosedBase(int period,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,double skew=0.0,AbstractSignal *aSubSignal=NULL);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
LastClosedBase::LastClosedBase(int period,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,double skew=0.0,AbstractSignal *aSubSignal=NULL):AbstractSignal(period,timeframe,shift,clrNONE,minimumSpreadsTpSl,aSubSignal)
  {
   this._skew=skew;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LastClosedBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);

   if(this._compare.IsNotBetween(this._skew,-0.49,0.49))
     {
      v.Result=false;
      v.AddMessage("Atr skew is out of range Min : - 0.49 max 0.49");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LastClosedBase::DoesSignalMeetRequirements()
  {
   if(!(AbstractSignal::DoesSignalMeetRequirements()))
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceRange LastClosedBase::CalculateRange(string symbol,int shift,double midPrice)
  {
   PriceRange pr;
   pr.mid=midPrice;
   double atr=(this.GetAtr(symbol,shift)/2);
   pr.low=(pr.mid-atr);
   pr.high=(pr.mid+atr);
   return pr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LastClosedBase::GetLastClosedTicketNumber(string symbol)
  {
   return OrderManager::GetLastClosedOrderTicket(symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LastClosedBase::SetBuySignal(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.ask);
   pr.mid=pr.mid-((pr.high-pr.low)*this._skew);
   pr.high=tick.ask+(pr.high-pr.mid);
   pr.low=tick.ask-(pr.mid-pr.low);

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_BUY;
   this.Signal.price=tick.ask;
   this.Signal.stopLoss=pr.low;
   this.Signal.takeProfit=pr.high;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LastClosedBase::SetSellSignal(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.bid);
   pr.mid=pr.mid+((pr.high-pr.low)*this._skew);
   pr.high=tick.bid+(pr.high-pr.mid);
   pr.low=tick.bid-(pr.mid-pr.low);

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_SELL;
   this.Signal.price=tick.bid;
   this.Signal.stopLoss=pr.high;
   this.Signal.takeProfit=pr.low;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LastClosedBase::SetBuyExits(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.ask);
   pr.mid=pr.mid-((pr.high-pr.low)*this._skew);
   pr.high=tick.ask+(pr.high-pr.mid);
   pr.low=tick.ask-(pr.mid-pr.low);
   
   double sl=pr.low;
   if(sl>0 && sl>OrderManager::PairHighestPricePaid(symbol,OP_BUY))
   {
      sl=OrderManager::PairHighestPricePaid(symbol,OP_BUY);
   }

   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_BUY;
   this.Signal.price=tick.ask;
   this.Signal.stopLoss=sl;
   this.Signal.takeProfit=OrderManager::PairHighestTakeProfit(symbol,OP_BUY);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LastClosedBase::SetSellExits(string symbol,int shift,MqlTick &tick)
  {
   PriceRange pr=this.CalculateRange(symbol,shift,tick.bid);
   pr.mid=pr.mid+((pr.high-pr.low)*this._skew);
   pr.high=tick.bid+(pr.high-pr.mid);
   pr.low=tick.bid-(pr.mid-pr.low);
   
   double sl=pr.high;
   if(sl>0 && sl<OrderManager::PairLowestPricePaid(symbol,OP_SELL))
   {
      sl=OrderManager::PairLowestPricePaid(symbol,OP_SELL);
   }
   
   this.Signal.isSet=true;
   this.Signal.time=tick.time;
   this.Signal.symbol=symbol;
   this.Signal.orderType=OP_SELL;
   this.Signal.price=tick.bid;
   this.Signal.stopLoss=sl;
   this.Signal.takeProfit=OrderManager::PairLowestTakeProfit(symbol,OP_SELL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LastClosedBase::SetExits(string symbol,int shift,MqlTick &tick)
  {
   if(0<OrderManager::PairProfit(symbol))
     {
      if(0<OrderManager::PairOpenPositionCount(OP_BUY,symbol,TimeCurrent()))
        {
         this.SetBuyExits(symbol,shift,tick);
        }
      if(0<OrderManager::PairOpenPositionCount(OP_SELL,symbol,TimeCurrent()))
        {
         this.SetSellExits(symbol,shift,tick);
        }
     }
  }
//+------------------------------------------------------------------+
