# Welcome to transform.el

transform.el lets you write a script in any language that transforms the currently selected region. The workflow is:

1. Mark the region you want to work on and run `M-x transform-start`.
2. A new buffer is opened in transform-mode with the content of the active region in it's `#input...#endinput` block. 
3. Create your transformation in the `#transform...#endtransform` block. Use shebang to specify the interpreter and access the input via stdin.
4. Test your transformation with `transform-run` (C-c C-r) and see the result in the `#output...#endoutput` block.
5. When you are satisfied with the transformation execute `transform-confirm` (C-c C-c) to replace the original region with the output of the transformation.

# Todo

* Screenshots
* Docs