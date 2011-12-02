function outdata=mkzeroconst(data)

 [n,p]=find(data<2);
 outdata=data;
 outdata(n,p)=2;   
    