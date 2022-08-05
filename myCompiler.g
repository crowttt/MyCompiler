grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
    import java.util.AbstractMap;
}

@members {
    boolean TRACEON = false;

    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, type, memory location>
	//    - type: the variable type   (please check "enum Type")
	//    - memory location: the location (locals in VM) the variable will be stored at.
	//
	// We use "AbstractMap.SimpleEntry"
	// type and memory location are stored as a AbstractMap.SimpleEntry<Type, Integer>.
	//
    // ============================================
    HashMap<String, AbstractMap.SimpleEntry> symtab = new HashMap<String, AbstractMap.SimpleEntry>();

    int labelCount = 0;
	 String temp;
	
	// storageIndex is used to represent/index the location (locals) in VM.
	// The first index is 0.
	int storageIndex = 0;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();

    // Type information.
    public enum Type{
       INT, FLOAT;
    }


    /*
     * Output prologue.
     */
    void prologue()
    {
       TextCode.add(";.source");
       TextCode.add(".class public static myResult");
       TextCode.add(".super java/lang/Object");
       TextCode.add(".method public static main([Ljava/lang/String;)V");

       /* The size of stack and locals should be properly set. */
       TextCode.add(".limit stack 100");
       TextCode.add(".limit locals 100");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       TextCode.add("return");
       TextCode.add(".end method");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

program: VOID MAIN '(' ')'
        {
           /* Output function prologue */
           prologue();
        }

        '{' 
           declarations
           statements
        '}'
        {
		   if (TRACEON)
		      System.out.println("VOID MAIN () {declarations statements}");

           /* output function epilogue */	  
           epilogue();
        }
        ;


declarations: type Identifier ';' declarations
              {
			         if (TRACEON)
	                  System.out.println("declarations: type Identifier : declarations");

                  if (symtab.containsKey($Identifier.text)) {
				    // variable re-declared.
                     System.out.println("Type Error: " + 
                                       $Identifier.getLine() + 
                                       ": Redeclared identifier.");
                    System.exit(0);
                 }
                 
				 /* Add ID and its attr_type into the symbol table. */
				 AbstractMap.SimpleEntry<Type,Integer> the_entry = new AbstractMap.SimpleEntry<Type, Integer>($type.attr_type, Integer.valueOf(storageIndex));
				 storageIndex = storageIndex + 1;
                 symtab.put($Identifier.text, the_entry);
            }
            | 
		      {
			     if (TRACEON)
                    System.out.println("declarations: ");
			   }
            ;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); attr_type=Type.INT; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); attr_type=Type.FLOAT; }
	;

statements:statement statements
          |
          ;

statement: assign_stmt ';'
         | if_stmt
         | printf ';'
         | for_stmt
         | while_stmt
         ;

for_stmt: FOR  
            '(' assign_stmt {TextCode.add(newLabel()+":");}';'
               cond_expression ';'
				  assign_stmt
			   ')'
			      block_stmt
            {
               TextCode.add("goto "+"L" + (labelCount-1));
               TextCode.add("L" + (labelCount)+":");
            }
        ;
while_stmt: WHILE
            {TextCode.add(newLabel()+":");}
            '(' cond_expression ')' block_stmt
            {
               TextCode.add("goto "+"L" + (labelCount-1));
               TextCode.add("L" + (labelCount)+":");
            }
         ;
		 
 
if_stmt
            : if_then_stmt if_else_stmt
            ;

if_then_stmt
            : IF '(' cond_expression ')' block_stmt
            {
               TextCode.add("goto "+newLabel());
               TextCode.add("L" + (labelCount-1)+":");
            }
            ;

if_else_stmt
            : ELSE block_stmt
            {
               TextCode.add("L" + (labelCount)+":");
            }
            |
            ;

				  
block_stmt: '{' statements '}' 
            | statement
	  ;


assign_stmt: Identifier 
            ('=' a=arith_expression
            {
			   Type the_type;
			   int the_mem;
			   
			   // get the ID's location and type from symtab.			   
			   the_type = (Type) symtab.get($Identifier.text).getKey();
			   the_mem = ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue();
			   
			   if (the_type != $a.attr_type) {
			      System.out.println("Type error!\n");
				   System.exit(0);
			   }
			   
			   // issue store insruction:
               // => store the top element of the operand stack into the locals.
			   switch (the_type) {
			   case INT:
			              TextCode.add("istore " + the_mem);
			              break;
			   case FLOAT:
                       TextCode.add("fstore " + the_mem);
			              break;
			   }
            }
            |
            
            '++'
            {
               Type the_type;
               int the_mem;
               the_mem = ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue();
               the_type = (Type) symtab.get($Identifier.text).getKey();
               if (the_type != Type.INT) {
			         System.out.println("Type error, excpect integer !\n");
				      System.exit(0);
			      }
               TextCode.add("iload " + ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue());
               TextCode.add("ldc " + "1");
               TextCode.add("iadd");
               TextCode.add("istore " + the_mem);
            }
            
            |
            '--'
            {
               Type the_type;
               int the_mem;
               the_mem = ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue();
               the_type = (Type) symtab.get($Identifier.text).getKey();
               if (the_type != Type.INT) {
			         System.out.println("Type error, excpect integer !\n");
				      System.exit(0);
			      }
               TextCode.add("ldc " + "-1");
               TextCode.add("iload " + ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue());
               TextCode.add("iadd");
               TextCode.add("istore " + the_mem);
            }
            
            |
            '+=' b=arith_expression
            {
               Type the_type;
               int the_mem;
               the_mem = ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue();
               the_type = (Type) symtab.get($Identifier.text).getKey();
               if (the_type != Type.INT) {
			         System.out.println("Type error, excpect integer !\n");
				      System.exit(0);
			      }
               TextCode.add("iload " + ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue());
               TextCode.add("iadd");
               TextCode.add("istore " + the_mem);
            }
            |
            '-=' c=arith_expression
            {
               Type the_type;
               int the_mem;
               the_mem = ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue();
               the_type = (Type) symtab.get($Identifier.text).getKey();
               if (the_type != Type.INT) {
			         System.out.println("Type error, excpect integer !\n");
				      System.exit(0);
			      }
               TextCode.add("ineg");
               TextCode.add("iload " + ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue());
               TextCode.add("iadd");
               TextCode.add("istore " + the_mem);
            }
            )
           ;

		   
printf: PRINTF 
         {
            TextCode.add("; print the value.");
            TextCode.add("getstatic java/lang/System/out Ljava/io/PrintStream;"); 
         }'(' argument ')'

                   ;


argument: arg (',' arg)*
         {
            TextCode.add("invokevirtual java/io/PrintStream/println(" + temp + ")V");
            temp = null;
         }
        ;

arg: arith_expression
   {
      if($arith_expression.attr_type==Type.INT)
      {
         if(temp==null)
            temp = "I";
         else
            temp = temp + ",I";
      }
      else if($arith_expression.attr_type==Type.FLOAT)
      {
         if(temp==null)
            temp = "F";
         else
            temp = temp + ",F";
      }
   }
   | STRING_LITERAL
   {
      TextCode.add("ldc " + $STRING_LITERAL.text);
      if(temp==null)
         temp = "Ljava/lang/String;";
      else
         temp = temp + ",Ljava/lang/String;";
   }
   ;
		   
cond_expression
returns [boolean truth]
               : a=arith_expression
			      {
				    if ($a.attr_type.ordinal() != 0)
					   truth = true;
					 else
					   truth = false;
				   }
                 (RelationOP b=arith_expression)*
                 {  						 
                     if ($a.attr_type != $b.attr_type) {
			               System.out.println("Type error!\n");
				            System.exit(0);
			            }
                     if(($a.attr_type == Type.INT) && ($b.attr_type == Type.INT))
                     {
                        switch($RelationOP.text)
                        {
                           case "<" :
                              TextCode.add("if_icmpge " + newLabel());
                              break;
                           case ">" :
                              TextCode.add("if_icmple " + newLabel());
                              break;
                           case "==" :
                              TextCode.add("if_icmpne " + newLabel());
                              break;
                           case "<=" :
                              TextCode.add("if_icmpgt " + newLabel());
                              break;
                           case ">=" :
                              TextCode.add("if_icmplt " + newLabel());
                              break;
                           case "!=" :
                              TextCode.add("if_icmpeq " + newLabel());
                              break;
                        }
                     }
                     if(($a.attr_type == Type.FLOAT) && ($b.attr_type == Type.FLOAT))
                     {
                        switch($RelationOP.text)
                        {
                           case "<" :
                              TextCode.add("fcmpl");
                              TextCode.add("ifge " + newLabel());
                              break;
                           case ">" :
                              TextCode.add("fcmpl");
                              TextCode.add("ifle " + newLabel());
                              break;
                           case "==" :
                              TextCode.add("fcmpl");
                              TextCode.add("ifne " + newLabel());
                              break;
                           case "<=" :
                              TextCode.add("fcmpl");
                              TextCode.add("ifgt " + newLabel());
                              break;
                           case ">=" :
                              TextCode.add("fcmpl");
                              TextCode.add("iflt " + newLabel());
                              break;
                           case "!=" :
                              TextCode.add("fcmpl");
                              TextCode.add("ifeq " + newLabel());
                              break;
                        }
                     }
                 }
               ;

			   
arith_expression
returns [Type attr_type]
                : a=multExpr { $attr_type = $a.attr_type; }

                  ( '+' b=multExpr
                     {

                    if ($attr_type != $b.attr_type) {
			               System.out.println("Type error!\n");
				            System.exit(0);
			            }

						  if (($attr_type == Type.INT) &&
						      ($b.attr_type == Type.INT))
						     TextCode.add("iadd");
						  
                    if (($attr_type == Type.FLOAT) &&
						      ($b.attr_type == Type.FLOAT))
						     TextCode.add("fadd");
                       
                     }
                       
                 | '-' c=multExpr
                  {
                    if ($attr_type != $c.attr_type) {
			               System.out.println("Type error!\n");
				            System.exit(0);
			            }

						  if (($attr_type == Type.INT) && ($c.attr_type == Type.INT)){
                        TextCode.add("ineg");
						      TextCode.add("iadd");
                     }
                    if (($attr_type == Type.FLOAT) && ($c.attr_type == Type.FLOAT)){
						      TextCode.add("fneg");
                        TextCode.add("fadd");
                    }                       
                  }
                  
                 )*
               
                 ;

multExpr
returns [Type attr_type]
          : a=signExpr { $attr_type=$a.attr_type; }
          ( '*' b=signExpr
          {
            if($attr_type != $b.attr_type){
               System.out.println("Type error!\n");
               System.exit(0);
            }
				if (($attr_type == Type.INT) && ($b.attr_type == Type.INT)){
					TextCode.add("imul");
            }
            if (($attr_type == Type.FLOAT) && ($b.attr_type == Type.FLOAT)){
               TextCode.add("fmul");
            }            

          }
          | '/' c=signExpr
          {
            if($attr_type != $c.attr_type){
               System.out.println("Type error!\n");
               System.exit(0);
            }
				if (($attr_type == Type.INT) && ($c.attr_type == Type.INT)){
					TextCode.add("idiv");
            }
            if (($attr_type == Type.FLOAT) && ($c.attr_type == Type.FLOAT)){
               TextCode.add("fdiv");
            }
          }
	  )*
	  ;

signExpr
returns [Type attr_type]
        : a=primaryExpr { $attr_type=$a.attr_type; } 
        | '-' b=primaryExpr
        {
				switch ($b.attr_type) {
				case INT: 
                  TextCode.add("ineg");
				case FLOAT:
                  TextCode.add("fneg");
            }
        }
	;
		  
primaryExpr
returns [Type attr_type] 
           : Integer_constant
		     {
			    $attr_type = Type.INT;
				
				// code generation.
				// push the integer into the operand stack.
				TextCode.add("ldc " + $Integer_constant.text);
			   }
           | Floating_point_constant
           {
              $attr_type = Type.FLOAT;
              TextCode.add("ldc " + $Floating_point_constant.text);
           }
           | Identifier
		     {
			    // get type information from symtab.
			    $attr_type = (Type) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getKey();
				
				switch ($attr_type) {
				case INT: 
				          // load the variable into the operand stack.
				          TextCode.add("iload " + ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue());
				          break;
				case FLOAT:
                      TextCode.add("fload " + ((Integer) ((AbstractMap.SimpleEntry) symtab.get($Identifier.text)).getValue()).intValue());
				          break;
				}
			 }
	   | '(' arith_expression ')' {$attr_type = $arith_expression.attr_type;}
           ;

		   
/* description of the tokens */
FLOAT:'float';
INT:'int';

MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
FOR: 'for';
WHILE: 'while';

PRINTF: 'printf';

RelationOP: '>' |'>=' | '<' | '<=' | '==' | '!=';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};


fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
