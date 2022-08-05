void main()
{
   int a;
   int b;
   int i;
   a = 100;
   b = 100;
 
   if(a>b){
         printf("yes i do");
   }
  
   else{
      printf("no i don't");
   }

   for(i=0;i<10;i++){
      a +=1;
      b -= 1;
      b--;
   }
   printf(a);
   printf(b);

   i=0;
   while(i<10){
      a -= 1;
      b += 1;
      b++ ;
      i++;
   }

   printf(a);
   printf(b);
}