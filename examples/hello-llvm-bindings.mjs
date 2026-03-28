/* Elementary example of using llvm-bindings to create a function that adds two integers */
/* 
Be sure to set the LLVM version before running this example to LLVM@14:

                source ./llvm-version.sh 14
Then run the example with:
                node examples/hello-llvm-bindings.mjs
This will print the following LLVM IR code:

                ; ModuleID = 'demo'
                source_filename = "demo"

                define i32 @add(i32 %0, i32 %1) {
                entry:
                %2 = add i32 %0, %1
                ret i32 %2
                }
*/
import llvm from 'llvm-bindings';

function main() {
    const context = new llvm.LLVMContext(); // Manages global data and compilation state
    const module = new llvm.Module('demo', context); // Represents a complete program, contains functions, global variables, etc.
    const builder = new llvm.IRBuilder(context); // Helps build LLVM instructions more easily

    const returnType = builder.getInt32Ty();
    const paramTypes = [builder.getInt32Ty(), builder.getInt32Ty()];
    const functionType = llvm.FunctionType.get(returnType, paramTypes, false);
    const func = llvm.Function.Create(
        functionType,                                // Function type
        llvm.Function.LinkageTypes.ExternalLinkage,  // Visibility: can be called from other modules
        'add',                                       // Function name
        module                                       // Module to which the function belongs
    );

    const entryBB = llvm.BasicBlock.Create(context, 'entry', func); // Entry basic block for the function
    builder.SetInsertPoint(entryBB); // Sets entryBB as the default basic block where all following instructions will be inserted
    const a = func.getArg(0); // IR AST node for the first parameter
    const b = func.getArg(1); // IR AST node for the second parameter
    const result = builder.CreateAdd(a, b); // Creates an IR AST for addition
    builder.CreateRet(result); // Creates an IR AST for returning the result of the addition

    if (llvm.verifyFunction(func)) { // See https://llvm.org/doxygen/Verifier_8h.html
        console.error('Verifying function failed');
        return;
    }
    if (llvm.verifyModule(module)) {
        console.error('Verifying module failed');
        return;
    }
    console.log(
        module.print() //Generates the LLVM IR code for the module
    ); 
}

main();