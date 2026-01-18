(import-macros _ :__)

(_.L M {:colorschemes [] :exports {}})

(fn M.exports.doTheThings []
  (set vim.opt.colorcolumn "80"))

M.exports
