//+------------------------------------------------------------------+
//|                                           MarketWatchMonitor.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\CsvFileWriter.mqh>
#include <MarketWatch\MarketWatch.mqh>
#include <Common\StaticIndicators.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MarketWatchMonitor : private CsvFileWriter
  {
private:

   string            _columnNames[];

   void ResetFile()
     {
      this.Open(this.FileName(),false);
      this.SetColumnNames(this._columnNames);
     }
public:

   void MarketWatchMonitor(string fileName="MarketWatch.csv"):CsvFileWriter(fileName,false)
     {
      string columns[]=
        {
         "Date"
            ,"Time"
            ,"Symbol"
            ,"Bid"
            ,"Ask"
            ,"Spread"
            ,"High"
            ,"Low"
            ,"Volume"
            ,"Last Deal Price"
            ,"Flag"
        };
      ArrayCopy(this._columnNames,columns);
      this.SetColumnNames(this._columnNames);
     };

   bool RecordData()
     {
      bool out=true;
      this.ResetFile();
      string symbols[];
      int ct=MarketWatch::GetWatchedSymbols(symbols);
      MqlTick tick;
      string symbol;

      for(int i=0;i<ct;i++)
        {
         symbol=symbols[i];
         if(MarketWatch::GetTick(symbol,tick))
           {
            this.SetPendingDataItem("Date",StringFormat("%i/%i/%i",TimeYear(tick.time),TimeMonth(tick.time),TimeDay(tick.time)));
            this.SetPendingDataItem("Time",StringFormat("%i:%i:%i",TimeHour(tick.time),TimeMinute(tick.time),TimeSeconds(tick.time)));
            this.SetPendingDataItem("Symbol",symbol);
            this.SetPendingDataItem("Bid",(string)tick.bid);
            this.SetPendingDataItem("Ask",(string)tick.ask);
            this.SetPendingDataItem("Spread",(string)MarketWatch::GetSpread(symbol));
            this.SetPendingDataItem("High",(string)StaticIndicators::GetHighPrice(symbol,0,PERIOD_D1));
            this.SetPendingDataItem("Low",(string)StaticIndicators::GetLowPrice(symbol,0,PERIOD_D1));
            this.SetPendingDataItem("Volume",(string)tick.volume);
            this.SetPendingDataItem("Last Deal Price",(string)tick.last);
            this.SetPendingDataItem("Flag",MarketWatch::GetTickFlagDescription(tick.flags));
            out=out && (this.WritePendingDataRow()>0);
           }
        }
      return out;
     };
  };
//+------------------------------------------------------------------+
