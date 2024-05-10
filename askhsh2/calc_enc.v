module calc_enc
(input wire A,B,C, output wire[3:0]  AL);

wire r0,r1,r2,r3,r5,r6,r7,r8,r10,r11,r12,r13,r15,r16,r17,r18;

not U0 (r0,A);
xor U1 (r1,B,C);
and U2 (r2,A,r1);
and U3 (r3,B,r0);
or U4 (AL[0],r2,r3); 

and U5 (r5,A,B);
not U6 (r6,B);
not U7 (r7,C);
and U8 (r8,r6,r7);
or U9 (AL[1],r8,r5);

and U10 (r10,A,B);
xor U11 (r11,A,B);
not U12 (r12,C);
or U13 (r13,r10,r11);
and U14 (AL[2],r12,r13);

not U15 (r15,A);
xnor U16(r16,A,C);
and U17(r17,C,r15);
or U18(r18,r17,r16);
and U19(AL[3],r18,B);

endmodule