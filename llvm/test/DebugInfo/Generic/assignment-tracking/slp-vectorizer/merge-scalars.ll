; REQUIRES: x86-registered-target
; RUN: opt -passes=slp-vectorizer -S -o - %s \
; RUN: | FileCheck %s

;; $ cat test.cpp
;; float get();
;; float ext(float*);
;; void fun(float k1, float k2, float k3, float k4) {
;;   float quad[4];
;;   float c1 = get();
;;   float c2 = get();
;;   quad[0] = c1 - k1 - k3;
;;   quad[1] = c2 - k2 - k4;
;;   quad[2] = c1 - k1 + k3;
;;   quad[3] = c2 - k2 + k4;
;;   ext(quad);
;; }
;;
;; Generated by grabbingthe IR before SLP in:
;; $ clang++ -O2 -g test.cpp -Xclang -fexperimental-assignment-tracking

;; Test that dbg.assigns linked to the the scalar stores to quad get linked to
;; the vector store that replaces them.

; CHECK: #dbg_assign(float poison, ![[VAR:[0-9]+]], !DIExpression(DW_OP_LLVM_fragment, 0, 32), ![[ID:[0-9]+]], ptr %arrayidx, !DIExpression(),
; CHECK: #dbg_assign(float poison, ![[VAR]], !DIExpression(DW_OP_LLVM_fragment, 32, 32), ![[ID]], ptr %quad, !DIExpression(DW_OP_plus_uconst, 4),
; CHECK: #dbg_assign(float poison, ![[VAR]], !DIExpression(DW_OP_LLVM_fragment, 64, 32), ![[ID]], ptr %quad, !DIExpression(DW_OP_plus_uconst, 8),
; CHECK: store <4 x float> {{.*}} !DIAssignID ![[ID]]
; CHECK: #dbg_assign(float poison, ![[VAR]], !DIExpression(DW_OP_LLVM_fragment, 96, 32), ![[ID]], ptr %quad, !DIExpression(DW_OP_plus_uconst, 12),

target triple = "x86_64-unknown-unknown"

define dso_local void @_Z3funffff(float %k1, float %k2, float %k3, float %k4) local_unnamed_addr #0 !dbg !7 {
entry:
  %quad = alloca [4 x float], align 16, !DIAssignID !27
  call void @llvm.dbg.assign(metadata i1 undef, metadata !16, metadata !DIExpression(), metadata !27, metadata ptr %quad, metadata !DIExpression()), !dbg !23
  call void @llvm.dbg.assign(metadata float %k1, metadata !12, metadata !DIExpression(), metadata !30, metadata ptr undef, metadata !DIExpression()), !dbg !23
  call void @llvm.dbg.assign(metadata float %k2, metadata !13, metadata !DIExpression(), metadata !31, metadata ptr undef, metadata !DIExpression()), !dbg !23
  call void @llvm.dbg.assign(metadata float %k3, metadata !14, metadata !DIExpression(), metadata !32, metadata ptr undef, metadata !DIExpression()), !dbg !23
  call void @llvm.dbg.assign(metadata float %k4, metadata !15, metadata !DIExpression(), metadata !33, metadata ptr undef, metadata !DIExpression()), !dbg !23
  %call = tail call float @_Z3getv(), !dbg !35
  call void @llvm.dbg.assign(metadata float %call, metadata !20, metadata !DIExpression(), metadata !36, metadata ptr undef, metadata !DIExpression()), !dbg !23
  %call1 = tail call float @_Z3getv(), !dbg !37
  call void @llvm.dbg.assign(metadata float %call1, metadata !21, metadata !DIExpression(), metadata !38, metadata ptr undef, metadata !DIExpression()), !dbg !23
  %sub = fsub float %call, %k1, !dbg !39
  %sub2 = fsub float %sub, %k3, !dbg !40
  %arrayidx = getelementptr inbounds [4 x float], ptr %quad, i64 0, i64 0, !dbg !41
  store float %sub2, ptr %arrayidx, align 16, !dbg !42, !DIAssignID !47
  call void @llvm.dbg.assign(metadata float %sub2, metadata !16, metadata !DIExpression(DW_OP_LLVM_fragment, 0, 32), metadata !47, metadata ptr %arrayidx, metadata !DIExpression()), !dbg !23
  %sub3 = fsub float %call1, %k2, !dbg !48
  %sub4 = fsub float %sub3, %k4, !dbg !49
  %arrayidx5 = getelementptr inbounds [4 x float], ptr %quad, i64 0, i64 1, !dbg !50
  store float %sub4, ptr %arrayidx5, align 4, !dbg !51, !DIAssignID !52
  call void @llvm.dbg.assign(metadata float %sub4, metadata !16, metadata !DIExpression(DW_OP_LLVM_fragment, 32, 32), metadata !52, metadata ptr %arrayidx5, metadata !DIExpression()), !dbg !23
  %add = fadd float %sub, %k3, !dbg !53
  %arrayidx7 = getelementptr inbounds [4 x float], ptr %quad, i64 0, i64 2, !dbg !54
  store float %add, ptr %arrayidx7, align 8, !dbg !55, !DIAssignID !56
  call void @llvm.dbg.assign(metadata float %add, metadata !16, metadata !DIExpression(DW_OP_LLVM_fragment, 64, 32), metadata !56, metadata ptr %arrayidx7, metadata !DIExpression()), !dbg !23
  %add9 = fadd float %sub3, %k4, !dbg !57
  %arrayidx10 = getelementptr inbounds [4 x float], ptr %quad, i64 0, i64 3, !dbg !58
  store float %add9, ptr %arrayidx10, align 4, !dbg !59, !DIAssignID !60
  call void @llvm.dbg.assign(metadata float %add9, metadata !16, metadata !DIExpression(DW_OP_LLVM_fragment, 96, 32), metadata !60, metadata ptr %arrayidx10, metadata !DIExpression()), !dbg !23
  %call11 = call float @_Z3extPf(ptr nonnull %arrayidx), !dbg !61
  ret void, !dbg !62
}

declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1
declare !dbg !63 dso_local float @_Z3getv() local_unnamed_addr #2
declare !dbg !66 dso_local float @_Z3extPf(ptr) local_unnamed_addr #2
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1
declare void @llvm.dbg.assign(metadata, metadata, metadata, metadata, metadata, metadata) #3

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !1000}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 12.0.0", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.cpp", directory: "/")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 12.0.0"}
!7 = distinct !DISubprogram(name: "fun", linkageName: "_Z3funffff", scope: !1, file: !1, line: 3, type: !8, scopeLine: 3, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !11)
!8 = !DISubroutineType(types: !9)
!9 = !{null, !10, !10, !10, !10}
!10 = !DIBasicType(name: "float", size: 32, encoding: DW_ATE_float)
!11 = !{!12, !13, !14, !15, !16, !20, !21}
!12 = !DILocalVariable(name: "k1", arg: 1, scope: !7, file: !1, line: 3, type: !10)
!13 = !DILocalVariable(name: "k2", arg: 2, scope: !7, file: !1, line: 3, type: !10)
!14 = !DILocalVariable(name: "k3", arg: 3, scope: !7, file: !1, line: 3, type: !10)
!15 = !DILocalVariable(name: "k4", arg: 4, scope: !7, file: !1, line: 3, type: !10)
!16 = !DILocalVariable(name: "quad", scope: !7, file: !1, line: 4, type: !17)
!17 = !DICompositeType(tag: DW_TAG_array_type, baseType: !10, size: 128, elements: !18)
!18 = !{!19}
!19 = !DISubrange(count: 4)
!20 = !DILocalVariable(name: "c1", scope: !7, file: !1, line: 5, type: !10)
!21 = !DILocalVariable(name: "c2", scope: !7, file: !1, line: 6, type: !10)
!22 = distinct !DIAssignID()
!23 = !DILocation(line: 0, scope: !7)
!24 = distinct !DIAssignID()
!25 = distinct !DIAssignID()
!26 = distinct !DIAssignID()
!27 = distinct !DIAssignID()
!28 = distinct !DIAssignID()
!29 = distinct !DIAssignID()
!30 = distinct !DIAssignID()
!31 = distinct !DIAssignID()
!32 = distinct !DIAssignID()
!33 = distinct !DIAssignID()
!34 = !DILocation(line: 4, column: 3, scope: !7)
!35 = !DILocation(line: 5, column: 14, scope: !7)
!36 = distinct !DIAssignID()
!37 = !DILocation(line: 6, column: 14, scope: !7)
!38 = distinct !DIAssignID()
!39 = !DILocation(line: 7, column: 16, scope: !7)
!40 = !DILocation(line: 7, column: 21, scope: !7)
!41 = !DILocation(line: 7, column: 3, scope: !7)
!42 = !DILocation(line: 7, column: 11, scope: !7)
!47 = distinct !DIAssignID()
!48 = !DILocation(line: 8, column: 16, scope: !7)
!49 = !DILocation(line: 8, column: 21, scope: !7)
!50 = !DILocation(line: 8, column: 3, scope: !7)
!51 = !DILocation(line: 8, column: 11, scope: !7)
!52 = distinct !DIAssignID()
!53 = !DILocation(line: 9, column: 21, scope: !7)
!54 = !DILocation(line: 9, column: 3, scope: !7)
!55 = !DILocation(line: 9, column: 11, scope: !7)
!56 = distinct !DIAssignID()
!57 = !DILocation(line: 10, column: 21, scope: !7)
!58 = !DILocation(line: 10, column: 3, scope: !7)
!59 = !DILocation(line: 10, column: 11, scope: !7)
!60 = distinct !DIAssignID()
!61 = !DILocation(line: 11, column: 3, scope: !7)
!62 = !DILocation(line: 12, column: 1, scope: !7)
!63 = !DISubprogram(name: "get", linkageName: "_Z3getv", scope: !1, file: !1, line: 1, type: !64, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!64 = !DISubroutineType(types: !65)
!65 = !{!10}
!66 = !DISubprogram(name: "ext", linkageName: "_Z3extPf", scope: !1, file: !1, line: 2, type: !67, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!67 = !DISubroutineType(types: !68)
!68 = !{!10, !69}
!69 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !10, size: 64)
!1000 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
