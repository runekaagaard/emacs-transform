# Welcome to transform.el

transform.el lets you write a script in any language that transforms the currently selected region. The workflow is:

1. Select the text you want to work on and run `M-x transform-start`.
2. A new buffer is opened in transform-mode. Create you transformation in the ´#transform...#endtransform´ block.
3. Test your transformation with `transform-run` (C-c C-r) and see the result in the ´#output...#endoutput´ block.
4. When you are satisfied with the transformation execute `transform-confirm` (C-c C-c) to replace the original content with the transformed.