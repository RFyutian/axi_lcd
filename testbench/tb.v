module tb;
    
reg clk;
reg rst_n;







initial
begin
    clk = 0;
    rst_n = 0;
    #50
    rst_n = 1;
end

always #1 clk = ~clk;

endmodule
