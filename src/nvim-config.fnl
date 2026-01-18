(import-macros _ :__)

(_.R Color :lua-color)
(_.R snacks)

(fn dbg [...] (snacks.debug.inspect ...))

(fn setup-plugin [require-path ...]
  ((. (require require-path) :setup) ...))

(fn bg-color []
  (let [hl-normal (vim.api.nvim_get_hl_by_name :Normal true)
        bg-decimal (. hl-normal :background)]
    (Color (string.format "#%06x" bg-decimal))))

(fn bounder [_l _h]
  (let [l (math.min _l _h)
        h (math.max _l _h)]
    #(math.max l (math.min $1 h))))

(fn limr [l] (bounder l (- 1 l)))

(_.L h-n11-red 0.967)
(_.L n11-names [:red
                :orange
                :amber
                :yellow
                :lime
                :green
                :cyan
                :blue
                :indigo
                :purple
                :magenta])

(fn n-tick [name]
  (-> {:red :orange
       :orange :amber
       :amber :yellow
       :yellow :lime
       :lime :green
       :green :cyan
       :cyan :blue
       :blue :indigo
       :indigo :purple
       :purple :magenta
       :magenta :red}
      (. name)))

(fn n-untick [name]
  (-> {:orange :red
       :amber :orange
       :yellow :amber
       :lime :yellow
       :green :lime
       :cyan :green
       :blue :cyan
       :indigo :blue
       :purple :indigo
       :magenta :purple
       :red :magenta}
      (. name)))

(fn h-add [h plus] (% (+ 1 h plus) 1))
(fn h-tick [h] (h-add h (/ 1 11)))
(fn h-untick [h] (h-add h (/ 10 11)))

; (_.L h-by-norm11-name {})
(_.L h-by-norm11-name (let [res {}]
                        (accumulate [h h-n11-red __ name (ipairs n11-names)]
                          (do
                            (tset res name h)
                            (h-tick h)))
                        res))

(fn hsv [h s v] (Color {: h : s : v}))

(fn _v [c]
  (let [(_h _s v) (c:hsv)] v))

(fn _v! [c v]
  (let [(h s _v) (c:hsv)]
    (hsv h s v)))

(fn _v# [c f]
  (_v! c (f (_v c))))

(fn _s [c]
  (let [(_h s) (c:hsv)] s))

(fn _s! [c s]
  (let [(h _s v) (c:hsv)]
    (hsv h s v)))

(fn _s# [c f]
  (_s! c (f (_s c))))

(fn _h [c]
  (let [(h) (c:hsv)] h))

(fn _h! [c h]
  (let [(_h s v) (c:hsv)]
    (hsv h s v)))

(fn _h# [c f]
  (_h! c (f (_h c))))

(fn to-fg [col r _l]
  (let [l (or _l 0.05)
        (h s v) (col:hsv)]
    (-> (hsv h s (if (> v 0.5)
                     (- v r)
                     (+ v r)))
        (_v# (limr l))
        (_s# (limr 0.15)))))

(fn to-bg [col r _l]
  (let [l (or _l 0.05)
        (h s v) (col:hsv)]
    (-> (hsv h s (if (> v 0.5)
                     (+ v r)
                     (- v r)))
        (_v# (limr l))
        (_s# (limr 0.15)))))

(fn to-ff [col r _l]
  (let [l (or _l 0.05)
        (h s v) (col:hsv)]
    (-> (hsv h s (+ v r))
        (_v# (limr l))
        (_s# (limr 0.15)))))

(_.L Thm {})

(fn h-dist [h1 h2]
  (math.min (* (- h1 h2) (- h1 h2)) (* (- h2 h1) (- h2 h1))))

(fn nearest-n11 [c]
  (fn c-dist [name]
    (h-dist (_h c) (. h-by-norm11-name name)))

  (-> (accumulate [min nil __ name (ipairs n11-names)]
        (if (_.nil? min)
            {: name :dist (c-dist name)}
            (let [dist (c-dist name)]
              (if (< dist min.dist)
                  {: dist : name}
                  min))))
      (. :name)))

(fn reset-theme []
  (fn c-dist [name]
    (h-dist (_h Thm.bg) (. h-by-norm11-name name)))

  (set Thm.bg (bg-color))
  (set Thm.root-n11-name (nearest-n11 Thm.bg))
  (set Thm.root-n11-h (if (< (c-dist (n-tick Thm.root-n11-name))
                             (c-dist (n-untick Thm.root-n11-name)))
                          (h-tick (_h Thm.bg))
                          (h-untick (_h Thm.bg))))

  (fn h-of [name]
    (h-add Thm.root-n11-h
           (- (. h-by-norm11-name name) (. h-by-norm11-name Thm.root-n11-name))))

  (fn Thm.strong-fg-of [name]
    (tostring (_h! (to-fg (to-ff Thm.bg 0.1) 0.7) (h-of name))))

  (fn Thm.faint-bg-of [name]
    (tostring (_h! (to-ff Thm.bg 0.1) (h-of name))))

  (fn Thm.faint-fg-of [name]
    (tostring (_h! (to-fg Thm.bg 0.4) (h-of name)))))

(_.L mkcolorscheme #{:_type :colorscheme :name $1 :setup $2})

(_.L colorschemes {})

(fn add-colorscheme [name ...]
  (tset colorschemes name (mkcolorscheme name ...)))

(fn add-neomodern-colorscheme [theme variant]
  (->> (fn []
         (setup-plugin :neomodern {: theme : variant})
         ((. (require :neomodern) :load))
         (set vim.o.background variant)
         (vim.cmd.colorscheme theme))
       (add-colorscheme (.. theme :- variant))))

(fn add-colorschemes []
  (->> (fn []
         (setup-plugin :tokyodark)
         (vim.cmd.colorscheme :tokyodark))
       (add-colorscheme :tokyodark))
  (add-neomodern-colorscheme :gyokuro :light)
  (add-neomodern-colorscheme :gyokuro :dark)
  (add-neomodern-colorscheme :hojicha :dark)
  (add-neomodern-colorscheme :hojicha :light)
  (add-neomodern-colorscheme :iceclimber :light)
  (add-neomodern-colorscheme :iceclimber :dark)
  (add-neomodern-colorscheme :roseprime :light)
  (add-neomodern-colorscheme :roseprime :dark))

(fn -- [tbl fn-prop ...] ((. tbl fn-prop) ...))

(fn on-colorscheme []
  (reset-theme)

  (fn hl [...] (vim.api.nvim_set_hl 0 ...))

  (comment "                                           ")
  (comment "                                           ")
  (comment "                                           ")
  (comment "         gitsigns                          ")
  (hl :GitSignsAdd {:fg (Thm.faint-fg-of :green)})
  (hl :GitSignsChange {:fg (Thm.faint-fg-of :cyan)})
  (hl :GitSignsDelete {:fg (Thm.faint-fg-of :red)})
  (hl :GitSignsStagedAdd {:fg (Thm.faint-fg-of :lime)})
  (hl :GitSignsStagedChange {:fg (Thm.faint-fg-of :blue)})
  (hl :GitSignsStagedUntracked {:fg (Thm.faint-fg-of :orange)})
  (hl :GitSignsStagedDelete {:fg (Thm.faint-fg-of :magenta)})
  (comment "                                           ")
  (comment "                                           ")
  (comment "                                           ")
  (comment "            org                            ")

  (fn org-hl [name] {:fg (Thm.strong-fg-of name) :bg (Thm.faint-bg-of name)})

  (hl "@org.headline.level1" (org-hl :yellow))
  (hl "@org.headline.level2" (org-hl :cyan))
  (hl "@org.headline.level3" (org-hl :purple))
  (hl "@org.headline.level4" (org-hl :lime))
  (hl "@org.headline.level5" (org-hl :blue))
  (hl "@org.headline.level6" (org-hl :amber))
  (hl "@org.headline.level7" (org-hl :indigo))
  (hl "@org.headline.level8" (org-hl :green))
  (comment "                                           ")
  (comment "                                           ")
  (comment "                                           "))

(fn _set-colorscheme [name]
  (vim.api.nvim_clear_autocmds {:group :gitsigns :event [:ColorScheme]})
  ((. colorschemes name :setup))
  (on-colorscheme))

(fn set-colorscheme [name ...]
  (when (. colorschemes name)
    (_set-colorscheme name)))

(fn pick-colorscheme []
  (vim.ui.select (icollect [name (pairs colorschemes)] name) {}
                 #(set-colorscheme $1)))

(fn vim-opts []
  (vim.cmd "set splitright")
  (vim.cmd "set splitbelow")
  (set vim.opt.colorcolumn "80"))

(fn gitsigns []
  (let [newchar "༴"
        newchar "᎙"
        newchar "᭩"
        newchar "🮖"
        newchar "🮘"
        newchar "▒"
        newchar "🭬"
        newchar "𜸮"
        signchars {:delete {:text "˯"}
                   :top-delete {:text "˄"}
                   :change-delete {:text "↜"}
                   :untracked {:text "-"}
                   :add {:text newchar}
                   :change {:text newchar}}]
    (->> {:signs signchars :signs_staged signchars}
         (setup-plugin :gitsigns))))

(fn completion []
  (comment (setup-plugin :blink.cmp)))

(_.M$
  (fn $1.exports.doTheThings []
    (vim-opts)
    (vim.api.nvim_create_user_command "PickColorscheme"
                                      (fn [] (pick-colorscheme)) {:nargs 0})
    (vim.api.nvim_create_user_command "ReloadFnl"
                                      (fn [...]
                                        (let [fennel (require :fennel)]
                                          (-- (fennel.dofile "/home/dz/Projects/nvim-config/src/nvim-config.fnl")
                                              :doTheThings)))
                                      {:nargs 0})
    (gitsigns)
    (completion)
    (vim.api.nvim_clear_autocmds {:group :gitsigns :event [:ColorScheme]})
    (vim.api.nvim_create_autocmd :ColorScheme {:callback on-colorscheme})
    (vim.api.nvim_create_autocmd :BufLeave
                                 {:pattern "*.org"
                                  :callback #(vim.cmd "set list")})
    (vim.api.nvim_create_autocmd :BufEnter
                                 {:pattern "*.org"
                                  :callback #(vim.cmd "set nolist")})
    (vim.api.nvim_create_autocmd :BufLeave
                                 {:pattern "*.org"
                                  :callback #(snacks.indent.enable)})
    (vim.api.nvim_create_autocmd :BufEnter
                                 {:pattern "*.org"
                                  :callback #(snacks.indent.disable)})
    (add-colorschemes)
    (set-colorscheme :roseprime-dark)))
