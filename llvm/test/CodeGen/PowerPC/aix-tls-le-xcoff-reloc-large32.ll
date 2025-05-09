; RUN: llc -verify-machineinstrs -mcpu=pwr7 -mattr=-altivec -mtriple powerpc-ibm-aix-xcoff \
; RUN:     -xcoff-traceback-table=false --code-model=large -filetype=obj -o %t.o < %s
; RUN: llvm-readobj --relocs --expand-relocs %t.o | FileCheck -D#NFA=2 --check-prefix=RELOC %s
; RUN: llvm-readobj --syms %t.o | FileCheck -D#NFA=2 --check-prefix=SYM %s
; RUN: llvm-objdump -D -r --symbol-description %t.o | FileCheck -D#NFA=2 --check-prefix=DIS %s

@ThreadLocalVarInit = thread_local(localexec) global i64 1, align 8
@VarInit = global i64 87, align 8
@IThreadLocalVarUninit = internal thread_local(localexec) global i64 0, align 8
@IThreadLocalVarUninit2 = internal thread_local(localexec) global i64 0, align 8
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull)

define void @storeITLUninit(i64 noundef %x) {
entry:
  %0 = tail call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @IThreadLocalVarUninit)
  store i64 %x, ptr %0, align 8
  ret void
}

define i64 @loadTLInit() {
entry:
  %0 = tail call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @ThreadLocalVarInit)
  %1 = load i64, ptr %0, align 8
  %2 = load i64, ptr @VarInit, align 8
  %add = add nsw i64 %2, %1
  ret i64 %add
}

define signext i64 @loadTLUninit() {
entry:
  %0 = tail call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @IThreadLocalVarUninit)
  store i64 1, ptr %0, align 8
  %1 = tail call align 8 ptr @llvm.threadlocal.address.p0(ptr align 8 @IThreadLocalVarUninit2)
  %2 = load i64, ptr %1, align 8
  %add = add nsw i64 %2, 1
  ret i64 %add
}

; RELOC:      File:
; RELOC-NEXT: Format: aixcoff-rs6000
; RELOC-NEXT: Arch: powerpc
; RELOC-NEXT: AddressSize: 32bit
; RELOC-NEXT: Relocations [
; RELOC:       Virtual Address: 0x12
; RELOC-NEXT:       Symbol: IThreadLocalVarUninit ([[#NFA+21]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 16
; RELOC-NEXT:       Type: R_TOCU (0x30)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x16
; RELOC-NEXT:       Symbol: IThreadLocalVarUninit ([[#NFA+21]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 16
; RELOC-NEXT:       Type: R_TOCL (0x31)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x18
; RELOC-NEXT:       Symbol: .__get_tpointer ([[#NFA+1]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 26
; RELOC-NEXT:       Type: R_RBA (0x18)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x4E
; RELOC-NEXT:       Symbol: ThreadLocalVarInit ([[#NFA+23]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 16
; RELOC-NEXT:       Type: R_TOCU (0x30)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x52
; RELOC-NEXT:       Symbol: ThreadLocalVarInit ([[#NFA+23]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 16
; RELOC-NEXT:       Type: R_TOCL (0x31)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x54
; RELOC-NEXT:       Symbol: .__get_tpointer ([[#NFA+1]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 26
; RELOC-NEXT:       Type: R_RBA (0x18)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0xBE
; RELOC-NEXT:       Symbol: IThreadLocalVarUninit2 ([[#NFA+27]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 16
; RELOC-NEXT:       Type: R_TOCU (0x30)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0xC2
; RELOC-NEXT:       Symbol: IThreadLocalVarUninit2 ([[#NFA+27]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 16
; RELOC-NEXT:       Type: R_TOCL (0x31)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x114
; RELOC-NEXT:       Symbol: IThreadLocalVarUninit ([[#NFA+31]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 32
; RELOC-NEXT:       Type: R_TLS_LE (0x23)
; RELOC-NEXT:     }
; RELOC:     Relocation {
; RELOC-NEXT:       Virtual Address: 0x118
; RELOC-NEXT:       Symbol: ThreadLocalVarInit ([[#NFA+29]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 32
; RELOC-NEXT:       Type: R_TLS_LE (0x23)
; RELOC-NEXT:     }
; RELOC:       Virtual Address: 0x120
; RELOC-NEXT:       Symbol: IThreadLocalVarUninit2 ([[#NFA+33]])
; RELOC-NEXT:       IsSigned: No
; RELOC-NEXT:       FixupBitValue: 0
; RELOC-NEXT:       Length: 32
; RELOC-NEXT:       Type: R_TLS_LE (0x23)
; RELOC-NEXT:     }

; SYM:      File:
; SYM-NEXT: Format: aixcoff-rs6000
; SYM-NEXT: Arch: powerpc
; SYM-NEXT: AddressSize: 32bit
; SYM-NEXT: Symbols [
; SYM:     Index: [[#NFA+1]]
; SYM-NEXT:     Name: .__get_tpointer
; SYM-NEXT:     Value (RelocatableAddress): 0x0
; SYM-NEXT:     Section: N_UNDEF
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_EXT (0x2)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+2]]
; SYM-NEXT:       SectionLen: 0
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 0
; SYM-NEXT:       SymbolType: XTY_ER (0x0)
; SYM-NEXT:       StorageMappingClass: XMC_PR (0x0)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }
; SYM:     Index: [[#NFA+21]]
; SYM-NEXT:     Name: IThreadLocalVarUninit
; SYM-NEXT:     Value (RelocatableAddress): 0x114
; SYM-NEXT:     Section: .data
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_HIDEXT (0x6B)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+22]]
; SYM-NEXT:       SectionLen: 4
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 2
; SYM-NEXT:       SymbolType: XTY_SD (0x1)
; SYM-NEXT:       StorageMappingClass: XMC_TE (0x16)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }
; SYM:     Index: [[#NFA+23]]
; SYM-NEXT:     Name: ThreadLocalVarInit
; SYM-NEXT:     Value (RelocatableAddress): 0x118
; SYM-NEXT:     Section: .data
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_HIDEXT (0x6B)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+24]]
; SYM-NEXT:       SectionLen: 4
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 2
; SYM-NEXT:       SymbolType: XTY_SD (0x1)
; SYM-NEXT:       StorageMappingClass: XMC_TE (0x16)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }
; SYM:     Index: [[#NFA+27]]
; SYM-NEXT:     Name: IThreadLocalVarUninit2
; SYM-NEXT:     Value (RelocatableAddress): 0x120
; SYM-NEXT:     Section: .data
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_HIDEXT (0x6B)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+28]]
; SYM-NEXT:       SectionLen: 4
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 2
; SYM-NEXT:       SymbolType: XTY_SD (0x1)
; SYM-NEXT:       StorageMappingClass: XMC_TE (0x16)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }
; SYM:     Index: [[#NFA+29]]
; SYM-NEXT:     Name: ThreadLocalVarInit
; SYM-NEXT:     Value (RelocatableAddress): 0x0
; SYM-NEXT:     Section: .tdata
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_EXT (0x2)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+30]]
; SYM-NEXT:       SectionLen: 8
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 3
; SYM-NEXT:       SymbolType: XTY_SD (0x1)
; SYM-NEXT:       StorageMappingClass: XMC_TL (0x14)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }
; SYM:     Index: [[#NFA+31]]
; SYM-NEXT:     Name: IThreadLocalVarUninit
; SYM-NEXT:     Value (RelocatableAddress): 0x8
; SYM-NEXT:     Section: .tbss
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_HIDEXT (0x6B)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+32]]
; SYM-NEXT:       SectionLen: 8
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 3
; SYM-NEXT:       SymbolType: XTY_CM (0x3)
; SYM-NEXT:       StorageMappingClass: XMC_UL (0x15)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }
; SYM:     Index: [[#NFA+33]]
; SYM-NEXT:     Name: IThreadLocalVarUninit2
; SYM-NEXT:     Value (RelocatableAddress): 0x10
; SYM-NEXT:     Section: .tbss
; SYM-NEXT:     Type: 0x0
; SYM-NEXT:     StorageClass: C_HIDEXT (0x6B)
; SYM-NEXT:     NumberOfAuxEntries: 1
; SYM-NEXT:     CSECT Auxiliary Entry {
; SYM-NEXT:       Index: [[#NFA+34]]
; SYM-NEXT:       SectionLen: 8
; SYM-NEXT:       ParameterHashIndex: 0x0
; SYM-NEXT:       TypeChkSectNum: 0x0
; SYM-NEXT:       SymbolAlignmentLog2: 3
; SYM-NEXT:       SymbolType: XTY_CM (0x3)
; SYM-NEXT:       StorageMappingClass: XMC_UL (0x15)
; SYM-NEXT:       StabInfoIndex: 0x0
; SYM-NEXT:       StabSectNum: 0x0
; SYM-NEXT:     }
; SYM-NEXT:   }

; DIS:      file format aixcoff-rs6000
; DIS:      Disassembly of section .text:
; DIS:      00000000 (idx: [[#NFA+5]]) .storeITLUninit:
; DIS-NEXT:                                       mflr 0
; DIS-NEXT:                                       stwu 1, -32(1)
; DIS-NEXT:                                       stw 0, 40(1)
; DIS-NEXT:                                       mr 5, 3
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                addis 3, 2, 0
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCU	(idx: [[#NFA+21]]) IThreadLocalVarUninit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 6, 0(3)
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCL	(idx: [[#NFA+21]]) IThreadLocalVarUninit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                bla 0
; DIS-NEXT: {{0*}}[[#ADDR]]: R_RBA  (idx: [[#NFA+1]])      .__get_tpointer[PR]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                add 3, 3, 6
; DIS-NEXT:                                       stw 4, 4(3)
; DIS-NEXT:                                       stw 5, 0(3)
; DIS-NEXT:                                       addi 1, 1, 32
; DIS-NEXT:                                       lwz 0, 8(1)
; DIS-NEXT:                                       mtlr 0
; DIS-NEXT:                                       blr
; DIS:      00000040 (idx: [[#NFA+7]]) .loadTLInit:
; DIS-NEXT:                                       mflr 0
; DIS-NEXT:                                       stwu 1, -32(1)
; DIS-NEXT:                                       stw 0, 40(1)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                addis 3, 2, 0
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCU       (idx: [[#NFA+23]]) ThreadLocalVarInit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 4, 4(3)
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCL       (idx: [[#NFA+23]]) ThreadLocalVarInit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                bla 0
; DIS-NEXT: {{0*}}[[#ADDR]]: R_RBA  (idx: [[#NFA+1]])      .__get_tpointer[PR]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                add 3, 3, 4
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 5, 0(3)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 3, 4(3)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                addis 4, 2, 0
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCU       (idx: [[#NFA+25]]) VarInit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 4, 8(4)
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCL       (idx: [[#NFA+25]]) VarInit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 6, 0(4)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 4, 4(4)
; DIS-NEXT:                                       addc 4, 4, 3
; DIS-NEXT:                                       adde 3, 6, 5
; DIS-NEXT:                                       addi 1, 1, 32
; DIS-NEXT:                                       lwz 0, 8(1)
; DIS-NEXT:                                       mtlr 0
; DIS-NEXT:                                       blr
; DIS:      00000090 (idx: [[#NFA+9]]) .loadTLUninit:
; DIS-NEXT:                                       mflr 0
; DIS-NEXT:                                       stwu 1, -32(1)
; DIS-NEXT:                                       stw 0, 40(1)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                addis 3, 2, 0
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCU       (idx: [[#NFA+21]]) IThreadLocalVarUninit[TE]
; DIS-NEXT:                                       li 5, 1
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 4, 0(3)
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCL       (idx: [[#NFA+21]]) IThreadLocalVarUninit[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                bla 0
; DIS-NEXT: {{0*}}[[#ADDR]]: R_RBA  (idx: [[#NFA+1]])      .__get_tpointer[PR]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                add 4, 3, 4
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                stw 5, 4(4)
; DIS-NEXT:                                       li 5, 0
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                stw 5, 0(4)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                addis 4, 2, 0
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCU       (idx: [[#NFA+27]]) IThreadLocalVarUninit2[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 4, 12(4)
; DIS-NEXT: {{0*}}[[#ADDR + 2]]: R_TOCL       (idx: [[#NFA+27]]) IThreadLocalVarUninit2[TE]
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                add 3, 3, 4
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 5, 0(3)
; DIS-NEXT: [[#%x, ADDR:]]: {{.*}}                lwz 3, 4(3)
; DIS-NEXT:                                       addic 4, 3, 1
; DIS-NEXT:                                       addze 3, 5
; DIS-NEXT:                                       addi 1, 1, 32
; DIS-NEXT:                                       lwz 0, 8(1)
; DIS-NEXT:                                       mtlr 0
; DIS-NEXT:                                       blr

; DIS:      Disassembly of section .data:
; DIS:      000000e8 (idx: [[#NFA+11]]) VarInit[RW]:
; DIS-NEXT:       e8: 00 00 00 00
; DIS-NEXT:       ec: 00 00 00 57
; DIS:      000000f0 (idx: [[#NFA+13]]) storeITLUninit[DS]:
; DIS-NEXT:       f0: 00 00 00 00
; DIS-NEXT: 000000f0:  R_POS        (idx: [[#NFA+5]]) .storeITLUninit
; DIS-NEXT:       f4: 00 00 01 14
; DIS-NEXT: 000000f4:  R_POS        (idx: [[#NFA+19]]) TOC[TC0]
; DIS-NEXT:       f8: 00 00 00 00
; DIS:      000000fc (idx: [[#NFA+15]]) loadTLInit[DS]:
; DIS-NEXT:       fc: 00 00 00 40
; DIS-NEXT: 000000fc:  R_POS        (idx: [[#NFA+7]]) .loadTLInit
; DIS-NEXT:       100: 00 00 01 14
; DIS-NEXT: 00000100:  R_POS        (idx: [[#NFA+19]]) TOC[TC0]
; DIS-NEXT:       104: 00 00 00 00
; DIS:      00000108 (idx: [[#NFA+17]]) loadTLUninit[DS]:
; DIS-NEXT:       108: 00 00 00 90
; DIS-NEXT: 00000108:  R_POS        (idx: [[#NFA+9]]) .loadTLUninit
; DIS-NEXT:       10c: 00 00 01 14
; DIS-NEXT: 0000010c:  R_POS        (idx: [[#NFA+19]]) TOC[TC0]
; DIS-NEXT:       110: 00 00 00 00
; DIS:      00000114 (idx: [[#NFA+21]]) IThreadLocalVarUninit[TE]:
; DIS-NEXT:       114: 00 00 00 08
; DIS-NEXT: 00000114:  R_TLS_LE     (idx: [[#NFA+31]]) IThreadLocalVarUninit[UL]
; DIS:      00000118 (idx: [[#NFA+23]]) ThreadLocalVarInit[TE]:
; DIS-NEXT:       118: 00 00 00 00
; DIS-NEXT: 00000118:  R_TLS_LE     (idx: [[#NFA+29]]) ThreadLocalVarInit[TL]
; DIS:      0000011c (idx: [[#NFA+25]]) VarInit[TE]:
; DIS-NEXT:       11c: 00 00 00 e8
; DIS-NEXT: 0000011c:  R_POS        (idx: [[#NFA+11]]) VarInit[RW]
; DIS:      00000120 (idx: [[#NFA+27]]) IThreadLocalVarUninit2[TE]:
; DIS-NEXT:       120: 00 00 00 10
; DIS-NEXT: 00000120:  R_TLS_LE     (idx: [[#NFA+33]]) IThreadLocalVarUninit2[UL]

; DIS:      Disassembly of section .tdata:
; DIS:      00000000 (idx: [[#NFA+29]]) ThreadLocalVarInit[TL]:
; DIS-NEXT:        0: 00 00 00 00
; DIS-NEXT:        4: 00 00 00 01

; DIS:      Disassembly of section .tbss:
; DIS:      00000008 (idx: [[#NFA+31]]) IThreadLocalVarUninit[UL]:
; DIS-NEXT: ...
; DIS:      00000010 (idx: [[#NFA+33]]) IThreadLocalVarUninit2[UL]:
; DIS-NEXT: ...

