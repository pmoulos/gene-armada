function outdata=mkoneconst(data)

 [n,p]=find(data<1);
 outdata=data;
 outdata(n,p)=1;   
    