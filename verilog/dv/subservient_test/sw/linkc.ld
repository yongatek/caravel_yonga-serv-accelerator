ENTRY(entry_point)
SECTIONS
{
    .text :
    {
        *(.text.entry_point);
        *(.text*);
    }

}