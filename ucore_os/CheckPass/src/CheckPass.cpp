
#define DEBUG_TYPE "EnclavePass"
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include <sstream>
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Analysis/CallGraphSCCPass.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/Analysis/CallGraph.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/CFG.h"
#include "llvm/Support/Debug.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/DerivedTypes.h"
#include "stdlib.h"
#include <fstream>
#include <iostream>

#define MAX 0xFFFF


using namespace llvm;
using namespace std;

namespace {

    struct CheckPass : public ModulePass {
        static char ID; // Pass identification, replacement for typeid

        CheckPass() : ModulePass(ID) {}

        virtual bool runOnModule(Module &M) {

            Module::iterator MB, ME;
            IRBuilder<> IRB(M.getContext());

            for (MB = M.begin(), ME = M.end(); MB != ME; MB++) {
                Function *F = &*MB;
                Function::iterator FB, FE;

                errs()<<"function name is:"<<F->getName()<<"\n";

                for (FB = F->begin(), FE = F->end(); FB != FE; FB++) {
                    bool Flag=false;
                    BasicBlock *B = &*FB;
                    BasicBlock::iterator BB,BE;
                    for (BB = FB->begin(), BE = FB->end(); BB != BE; BB++) {
                        Instruction *I = &*BB;
                        if (!(dyn_cast<AllocaInst>(I))){
                            Flag=true;
                        }
                        if(FB==F->begin()&&BB==FB->begin()){
                            if(F->getName()=="main"){
                                IRB.SetInsertPoint(I);
                                llvm::FunctionType *FTy1= llvm::FunctionType::get(IRB.getVoidTy(), {IRB.getInt8PtrTy()},false);
                                llvm::FunctionType *FTy2=FunctionType::get(IRB.getInt8PtrTy(),false);
                                Value * _rip=IRB.CreateCall(llvm::InlineAsm::get(FTy2,"leal 8(%eip),$0\n\t","=r",true));
                                Constant *GenFunc = M.getOrInsertFunction("gen_execend", FTy1);

                                IRB.CreateCall(GenFunc,{_rip});


                            }
                            if(F->getName()!="main") {
                                errs() << "breakpoint\n";
                                IRB.SetInsertPoint(I);
                                llvm::FunctionType *FTy = llvm::FunctionType::get(IRB.getVoidTy(), {IRB.getVoidTy()}, false);
                                Constant *CheckFunc = M.getOrInsertFunction("check_exec", FTy);
                                IRB.CreateCall(CheckFunc);
                                //IRB.CreateCall(CheckFunc,{_rip});
                                Flag = false;
                            }
                        }
                    }
                }

                //BasicBlock *B = &*FB;
                //BasicBlock::iterator BB;
                //BB=B->begin();
                //Instruction *CI = &*BB;
                //IRB.SetInsertPoint(CI);
                //llvm::FunctionType *FTy = llvm::FunctionType::get(IRB.getVoidTy(),{IRB.getVoidTy()},false);
                //Constant* CheckFunc = M.getOrInsertFunction("check_exec", FTy);
            }
          //  outfile.close();
        }
    };
}

char CheckPass::ID = 0;


static void registerCheckPass(const PassManagerBuilder &,
                                legacy::PassManagerBase &PM) {
    PM.add(new CheckPass());
}
static RegisterStandardPasses
        RegisterMyPass(PassManagerBuilder::EP_ModuleOptimizerEarly, registerCheckPass);

static RegisterStandardPasses
        RegisterMyPass0(PassManagerBuilder::EP_EnabledOnOptLevel0, registerCheckPass);




