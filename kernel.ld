/******************************************************************************
*	kernel.ld
*	 by Alex Chadwick
*
*	A linker script for generation of raspberry pi kernel images.
******************************************************************************/

SECTIONS
{
	//hardware expects the start of the program to be at 0x8000
	//so the first codeblock starts at .init
	.init 0x8000 :
	{
		*(.init)
	}
	//the other sections follow after init
	.text :
	{
		*(.text)
	}
	//data comes after text
	.data :
	{
		*(.data)
	}

	//new sections go here
	/DISCARD/ :
	{
		*(*)
	}
}
