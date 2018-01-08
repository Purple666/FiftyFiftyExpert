#property  copyright "Copyright © 2005, Yura Prokofiev"
#property  link      "Yura.prokofiev@gmail.com"

#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Black
#property  indicator_color2  Lime
#property  indicator_color3  Red
 
extern int period=15;

double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];

int init()
  {
    
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   IndicatorDigits(Digits+1);

   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);

   IndicatorShortName("SOLAR WIND");
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);

   return(0);
  }

int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;  
   
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;


   for(int i=0; i<limit; i++)
    {  MaxH = High[iHighest(NULL,0,MODE_HIGH,period,i)];
       MinL = Low[iLowest(NULL,0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
      Value=MathMin(MathMax(Value,-0.999),0.999); 
      ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      Value1=Value;
      Fish1=ExtBuffer0[i];
    }

   bool up=true;
   for(i=limit-2; i>=0; i--)
     {
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
           
      if (((current<0)&&(prev>0))||(current<0))   up= false;    
      if (((current>0)&&(prev<0))||(current>0))   up= true;
      
      if(!up)
        {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
        }
        
       else
         {
          ExtBuffer1[i]=current;
          ExtBuffer2[i]=0.0;
         }
     }

   return(0);
  }
  //+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- The first way to get the uninitialization reason code 
//Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| GetRelativeProgramPath                                           |
//+------------------------------------------------------------------+
string GetRelativeProgramPath()
  {
   int pos2;
//--- get the absolute path to the application
   string path=MQLInfoString(MQL_PROGRAM_PATH);
//--- find the position of "\MQL4\" substring
   int    pos=StringFind(path,"\\MQL4\\");
//--- substring not found - error
   if(pos<0)
      return(NULL);
//--- skip "\MQL4" directory
   pos+=5;
//--- skip extra '\' symbols
   while(StringGetCharacter(path,pos+1)=='\\')
      pos++;
//--- if this is a resource, return the path relative to MQL4 directory
   if(StringFind(path,"::",pos)>=0)
      return(StringSubstr(path,pos));
//--- find a separator for the first MQL4 subdirectory (for example, MQL4\Indicators)
//--- if not found, return the path relative to MQL4 directory
   if((pos2=StringFind(path,"\\",pos+1))<0)
      return(StringSubstr(path,pos));
//--- return the path relative to the subdirectory (for example, MQL4\Indicators)
   return(StringSubstr(path,pos2+1));
  }
//+------------------------------------------------------------------+
