package com.example.android.bluetoothchat;

class Macros {
    final byte[] allOn =        {(byte)0x7e, (byte)0x00, (byte)0x01, (byte)0xff, (byte)0x01, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] allOff =       {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x7f};
    final byte[] blink =        {(byte)0x7e, (byte)0x00, (byte)0x01, (byte)0xff, (byte)0x00, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] llLeft =       {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x01, (byte)0x01, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] llRight =      {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x01, (byte)0x02, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] tripleLeft =   {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x07, (byte)0x01, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] tripleRight =  {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x07, (byte)0x02, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] speedTriple =  {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x07, (byte)0x02, (byte)0x01, (byte)0x00, (byte)0x20, (byte)0x7f};
    final byte[] triOnTri =     {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0x07, (byte)0x02, (byte)0x03, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] llHalfon =     {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0xaa, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0xc8, (byte)0x7f};
    final byte[] emptyMove =    {(byte)0x7e, (byte)0x00, (byte)0x00, (byte)0xff, (byte)0x01, (byte)0x01, (byte)0x00, (byte)0xc8, (byte)0x7f};

    final byte[] quicker =      {(byte)0x7e, (byte)0x01, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x19, (byte)0x7f};
    final byte[] slower =       {(byte)0x7e, (byte)0x02, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x19, (byte)0x7f};
}