(import-macros _ :__)

(_.R snacks)

(_.L module {})

(fn module.doTheThings []
  (set vim.opt.colorcolumn "80")
  ((. snacks :debug :inspect) {:fnl "using macro!!!!"}))

module
