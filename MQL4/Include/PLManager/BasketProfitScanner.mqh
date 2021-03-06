//+------------------------------------------------------------------+
//|                                          BasketProfitScanner.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Generic\HashMap.mqh>
#include <Common\BaseSymbolScanner.mqh>
#include <Common\OrderManager.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class BasketProfitScanner : public BaseSymbolScanner
  {
private:
   OrderManager      orderManager;
   double            GetNetProfit(bool sendComment=false);
   void              ResetSymbolNets();
   void              Clear();
public:
   double            NetProfit;
   CHashMap<string,double>SymbolNets;
   string            Comments;
   void              BasketProfitScanner(SymbolSet *aSymbolSet);
   void              PerSymbolAction(string symbol);
   void              BasketProfitScanner::Scan();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BasketProfitScanner::BasketProfitScanner(SymbolSet *aSymbolSet):BaseSymbolScanner(aSymbolSet)
  {
   this.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasketProfitScanner::ResetSymbolNets()
  {
   this.SymbolNets.Clear();
   int i=0;
   int ct=this.symbolSet.Symbols.Count();
   string sym="";
   for(i=0;i<ct;i++)
     {
      if(this.symbolSet.Symbols.TryGetValue(i,sym))
        {
         this.SymbolNets.Add(sym,0);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasketProfitScanner::Clear()
  {
   this.Comments="";
   this.NetProfit=0;
   this.ResetSymbolNets();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BasketProfitScanner::PerSymbolAction(string symbol)
  {
   double p=orderManager.PairProfit(symbol);
   this.SymbolNets.TrySetValue(symbol,p);
   this.NetProfit+=p;
   this.Comments+=StringFormat("%s : %f\r\n",symbol,p);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BasketProfitScanner::Scan()
  {
   this.Clear();
   BaseSymbolScanner::Scan();
  }
//+------------------------------------------------------------------+
