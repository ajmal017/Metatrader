//+------------------------------------------------------------------+
//|                                                  HighLowBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HighLowBase : public AbstractSignal
  {
protected:
   Comparators       _compare;
   virtual PriceRange CalculateRange(string symbol,int shift);

public:
                     HighLowBase(int period,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HighLowBase::HighLowBase(int period,ENUM_TIMEFRAMES timeframe,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrAquamarine):AbstractSignal(period,timeframe,shift,indicatorColor,minimumSpreadsTpSl)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HighLowBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HighLowBase::DoesSignalMeetRequirements()
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
PriceRange HighLowBase::CalculateRange(string symbol,int shift)
  {
   PriceRange pr;
   pr.low=this.GetLowestPriceInRange(symbol,shift);
   pr.high=this.GetHighestPriceInRange(symbol,shift);
   pr.mid=Stats::Quotient(Stats::Sum(pr.high,pr.low),2.0);
   return pr;
  }
//+------------------------------------------------------------------+
