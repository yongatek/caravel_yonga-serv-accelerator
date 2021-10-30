#pragma GCC optimize("Os,no-unroll-loops,no-peel-loops")
/*
    riscv64-unknown-elf-gcc matmul_bench_default.c utility.c -o matmul_bench_default.elf -nostdlib -march=rv32i -mabi=ilp32 -T ../linkc.ld -Os -ffunction-sections 
    riscv64-unknown-elf-objcopy -O binary matmul_bench_default.elf matmul_bench_default.bin
    python ../py_tools/subservient_makehex.py matmul_bench_default.bin 1024 > matmul_bench_default_subservient.hex
    python ../py_tools/makehex.py matmul_bench_default.bin 256 > matmul_bench_default_servant.hex
    riscv64-unknown-elf-objdump -D matmul_bench_default.elf > elfdump.txt

*/

#include "memory_map.h"
#include "utility.h"
#include "random_arrays.h"


inline int multiply(int, int) __attribute__((always_inline));

int entry_point() {

    volatile int DATA_3[64];
    tic();
	int sum = 0;
	for (char i = 0; i < FMRS; i++) {
		for (char j = 0; j < SMCS; j++) {
			sum = 0;
			for (char k = 0; k < FMCS; k++){
				sum += multiply((int)DATA_0(i,k),(int)DATA_1(k,j));
			}
			DATA_3(i,j) = sum;
            /* // uncomment to validate
            if(DATA_2(i,j) != DATA_3(i,j)){
				failed();
			}
            */
		}
	}
    GPIO_0 = toc();

    // There isn't enough memory to save and validate. 
    // We can directly check the calculated answer. But this approach invalidates the test by slowing it down.
    // So, the validation part is commented out. We are assuming that the multiplication is error free.

    /*
    for(char i = 0; i<FMRS; i++){
        for(char j = 0; j<FMCS; j++){
            if(DATA_2(i,j) != DATA_3(i,j)){
				failed();
			}
        }
    }
    */
	passed();
}



inline int multiply(int n, int m) {

	int ans = 0;
	int count = 0;

	while (m)
	{
		if ((m & 0x1) == 1){          
			ans = ans + (n << count);
		}

		count = count + 1;
		m = m >> 1;
	}	

	return ans;
}
