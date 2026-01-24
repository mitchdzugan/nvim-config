(import-macros _ :__)

(_.module
 (fn hl [...] (vim.api.nvim_set_hl 0 ...))
 (import NColor :Color)
 (import | :utils)
 (import Color :lua-color)
 (import snacks)
 (import paredit :nvim-paredit)
 (|.dbg NColor)

 (fn setup-plugin [require-path ...]
   ((. (require require-path) :setup) ...))

 (fn bg-color []
   (let [hl-normal (vim.api.nvim_get_hl_by_name :Normal true)
         bg-decimal (or (. hl-normal :background) 0)]
     (Color (string.format "#%06x" bg-decimal))))

 (fn bounder [_l __h]
   (let [_h (if (_.nil? __h) (- 1 _l) __h)
         l (math.min _l _h)
         h (math.max _l _h)]
     #(math.max l (math.min $1 h))))

 (fn limr [l] (bounder l (- 1 l)))

 (loc h-n11-red 0.970)
 (loc n11-names [:red
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

 (fn h-untick [h] (h-add h (/ 10 11))) ; (_.L h-by-norm11-name {})
 (loc h-by-norm11-name (let [res {}]
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

 (fn to-sat-fg [col r _l]
   (let [l (or _l 0.05)
         (h s v) (col:hsv)]
     (-> (hsv h s (if (> v 0.5)
                      (- v r)
                      (+ v r)))
         (_v# (limr l))
         (_s# (limr 0.45)))))

 (comment (fn to-bg [col r _l]
            (let [l (or _l 0.05)
                  (h s v) (col:hsv)]
              (-> (hsv h s (if (> v 0.5)
                               (+ v r)
                               (- v r)))
                  (_v# (limr l))
                  (_s# (limr 0.15))))))

 (fn to-ff [col r _l]
   (let [l (or _l 0.05)
         (h s v) (col:hsv)]
     (-> (hsv h s (+ v r))
         (_v# (limr l))
         (_s# (limr 0.15)))))

 (loc Thm {})

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

   (fn Thm.sat-fg-of [name]
     (tostring (_h! (to-sat-fg (to-ff Thm.bg 0.1) 0.4) (h-of name))))

   (fn Thm.strong-fg-of [name]
     (tostring (_h! (to-fg (to-ff Thm.bg 0.1) 0.7) (h-of name))))

   (fn Thm.faint-bg-of [name]
     (tostring (_h! (to-ff Thm.bg 0.1) (h-of name))))

   (fn Thm.faint-fg-of [name]
     (tostring (_h! (to-fg Thm.bg 0.4) (h-of name)))))

 (loc mkcolorscheme #{:_type :colorscheme :name $1 :setup $2})
 (loc colorschemes {})

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
          (set vim.g.aurora_italic 1)
          (set vim.g.aurora_transparent 0)
          (set vim.g.aurora_bold 1)
          (set vim.g.aurora_darker 0)
          (require :aurora)
          (vim.cmd.colorscheme :aurora))
        (add-colorscheme :aurora))
   (->> (fn []
          (set vim.o.background :light)
          (vim.cmd.colorscheme :rose-pine-dawn))
        (add-colorscheme :rose-pine-dawn))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :rose-pine-moon))
        (add-colorscheme :rose-pine-moon))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :rose-pine-main))
        (add-colorscheme :rose-pine-main))
   (->> (fn []
          (set vim.o.background :light)
          (vim.cmd.colorscheme :melange))
        (add-colorscheme :melange-light))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :melange))
        (add-colorscheme :melange-dark))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :kanagawa-wave))
        (add-colorscheme :kanagawa-wave))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :kanagawa-dragon))
        (add-colorscheme :kanagawa-dragon))
   (->> (fn []
          (set vim.o.background :light)
          (vim.cmd.colorscheme :kanagawa-lotus))
        (add-colorscheme :kanagawa-lotus))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :dracula))
        (add-colorscheme :dracula))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :dracula-soft))
        (add-colorscheme :dracula-soft))
   (->> (fn []
          (set vim.o.background :light)
          (vim.cmd.colorscheme :catppuccin-latte))
        (add-colorscheme :catppuccin-latte))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :catppuccin-frappe))
        (add-colorscheme :catppuccin-frappe))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :catppuccin-macchiato))
        (add-colorscheme :catppuccin-macchiato))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :catppuccin-mocha))
        (add-colorscheme :catppuccin-mocha))
   (->> (fn []
          (set vim.o.background :dark)
          (vim.cmd.colorscheme :aylin)
          (hl :ColorColumn {:bg (tostring (Color {:h 0.8 :s 0.3 :v 0.25}))}))
        (add-colorscheme :aylin))
   (->> (fn []
          (set vim.o.background :dark)
          (setup-plugin :monet {})
          (vim.cmd.colorscheme :monet))
        (add-colorscheme :monet))
   (->> (fn []
          (vim.cmd.colorscheme :oldworld))
        (add-colorscheme :oldworld))
   (->> (fn []
          (setup-plugin :tokyodark)
          (vim.cmd.colorscheme :tokyodark))
        (add-colorscheme :tokyodark))
   (->> (fn []
          (setup-plugin :fluoromachine
                        {:glow true :transparent false :theme :delta})
          (vim.cmd.colorscheme :fluoromachine))
        (add-colorscheme :fluoromachine))
   (add-colorscheme :moonfly
                    (fn []
                      (set vim.o.background :dark)
                      (vim.cmd.colorscheme :moonfly)))
   (add-neomodern-colorscheme :gyokuro :light)
   (add-neomodern-colorscheme :gyokuro :dark)
   (add-neomodern-colorscheme :hojicha :dark)
   (add-neomodern-colorscheme :hojicha :light)
   (add-neomodern-colorscheme :iceclimber :light)
   (add-neomodern-colorscheme :iceclimber :dark)
   (add-neomodern-colorscheme :roseprime :light)
   (add-neomodern-colorscheme :roseprime :dark))

 (fn on-colorscheme []
   (reset-theme)
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

   (fn org-hl [name]
     {:fg (Thm.strong-fg-of name) :bg (Thm.faint-bg-of name)})

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
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "            snacks                         ")

   (fn org-hl [name]
     {:fg (Thm.strong-fg-of name) :bg (Thm.faint-bg-of name)})

   (hl "SnacksIndent1" (org-hl :orange))
   (hl "SnacksIndent2" (org-hl :lime))
   (hl "SnacksIndent3" (org-hl :blue))
   (hl "SnacksIndent4" (org-hl :yellow))
   (hl "SnacksIndent5" (org-hl :cyan))
   (hl "SnacksIndent6" (org-hl :amber))
   (hl "SnacksIndent7" (org-hl :purple))
   (hl "SnacksIndent8" (org-hl :green))
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
   (comment "         rainbow delim                     ")

   (fn rnbw-fg [name] (Thm.sat-fg-of name))

   (hl :RainbowDelimiterBlue {:fg (rnbw-fg :lime)})
   (hl :RainbowDelimiterViolet {:fg (rnbw-fg :indigo)})
   (hl :RainbowDelimiterOrange {:fg (rnbw-fg :amber)})
   (hl :RainbowDelimiterGreen {:fg (rnbw-fg :magenta)})
   (hl :RainbowDelimiterCyan {:fg (rnbw-fg :yellow)})
   (hl :RainbowDelimiterRed {:fg (rnbw-fg :purple)})
   (hl :RainbowDelimiterYellow {:fg (rnbw-fg :red)})
   (hl :Cursor {:bg (-> (Thm.strong-fg-of :amber)
                        (Color)
                        (tostring))})
   (hl :MatchParen {:fg (Thm.strong-fg-of :amber)
                    :bg (-> (Thm.faint-bg-of :amber)
                            (Color)
                            (_s# (bounder 0.8 1.0))
                            (_v# (bounder 0.4))
                            (tostring))
                    :bold true})
   (comment "                                           ")
   (comment "                                           ")
   (comment "                                           ")
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

 (fn sorted-colorschemes []
   (let [res (icollect [name (pairs colorschemes)] name)]
     (|.dbg res)
     (table.sort res)
     res))

 (fn pick-colorscheme []
   (vim.ui.select (sorted-colorschemes) {} #(set-colorscheme $1)))

 (fn setup-vim-opts []
   (comment) ; enable filetype based features
   (vim.cmd "filetype plugin indent on")
   (vim.cmd "syntax on")
   (vim.cmd "set termguicolors")
   (comment) ; split directions
   (vim.cmd "set splitright")
   (vim.cmd "set splitbelow")
   (comment) ; TODO look into these more. copied from copied from copied from etc. etc.
   (vim.cmd "set rnu")
   (vim.cmd "set nocompatible")
   (vim.cmd "set showtabline=2")
   (vim.cmd "set scl=yes")
   (vim.cmd "set number")
   (vim.cmd "set cursorline")
   (vim.cmd "set hidden")
   (vim.cmd "set visualbell")
   (vim.cmd "set t_vb=")
   (vim.cmd "set mouse=a")
   (comment) ; tab default stuff
   (vim.cmd "set expandtab")
   (vim.cmd "set tabstop=2")
   (vim.cmd "set shiftwidth=2")
   (vim.cmd "set nowrap")
   (comment) ; escape tmux thing  I think
   (vim.cmd "set t_ZH=␛[3m")
   (vim.cmd "set t_ZR=␛[23m")
   (comment) ; leaders
   (set vim.g.mapleader ";")
   (set vim.g.maplocalleader "\\")
   (comment) ; bg textures
   (vim.cmd "set list lcs=trail:·,tab:🮙🮙,lead:🮙")
   (comment) ; copy/paste
   (vim.cmd "set clipboard+=unnamedplus")
   (comment) ; make status bar less annoying. not sure if good
   (vim.cmd "set noshowcmd")
   (comment) ; start with closed folds
   (vim.cmd "set foldlevelstart=99")
   (comment) ; guicursor")
   (vim.cmd "set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175")
   (comment) ; long line indicator
   (set vim.opt.colorcolumn "80"))

 (fn setup-gitsigns []
   (let [newchar "𜸮"
         signchars {:delete {:text "˯"}
                    :top-delete {:text "˄"}
                    :change-delete {:text "↜"}
                    :untracked {:text "-"}
                    :add {:text newchar}
                    :change {:text newchar}}]
     (->> {:signs signchars :signs_staged signchars}
          (setup-plugin :gitsigns))))

 (import cmp)

 (fn setup-completion []
   (comment "did not like blink" (setup-plugin :blink.cmp))
   (-> {:snippet {:expand #(_.|| vim.fn "vsnip#anonymous" & $1.body)}
        :window {}
        :mapping (-> {"<C-b>" (cmp.mapping.scroll_docs -4)
                      "<C-f>" (cmp.mapping.scroll_docs 4)
                      "<C-Space>" (cmp.mapping.complete)
                      "<C-e>" (cmp.mapping.abort)
                      "<CR>" (cmp.mapping.confirm {:select true})
                      "<Tab>" (cmp.mapping.confirm {:select false})}
                     cmp.mapping.preset.insert)
        :sources (cmp.config.sources [{:name :nvim_lsp}
                                      {:name :vsnip}
                                      {:name :conjure}]
                                     [{:name :buffer}])}
       cmp.setup))

 (fn kset [modes lhs rhs opts]
   (vim.keymap.set modes lhs rhs (_.assign {:noremap true} (or opts {}))))

 (fn launch-best-repl []
   (snacks.terminal "fennel"))

 (fn setup-keymap []
   (|.ksetm "<A-q>"
            #(|.km "main menu" [:c "set colorscheme" #(pick-colorscheme)]
                   [:v
                    "edit vim config"
                    (.. "e " (os.getenv :DZ_NVIM_CONFIG_CHECKOUT_PATH))]))
   (|.ksetn "<AS-CR>" #(do
                         (paredit.api.move_to_parent_form_end)
                         (vim.api.nvim_input "i<CR>")))
   (|.ksetn "<S-CR>"
            #(do
               (paredit.api.move_to_next_element_tail)
               (vim.api.nvim_input "a<CR><Space><Left>")))
   (|.ksetn "<A-CR>"
            #(do
               (paredit.api.move_to_parent_form_end)
               (vim.api.nvim_input "a<CR><Space><Left>")))
   (|.ksetm "<A-1>" "1gt")
   (|.ksetm "<A-2>" "2gt")
   (|.ksetm "<A-3>" "3gt")
   (|.ksetm "<A-4>" "4gt")
   (|.ksetm "<A-5>" "5gt")
   (|.ksetm "<A-6>" "6gt")
   (|.ksetm "<A-7>" "7gt")
   (|.ksetm "<A-8>" "8gt")
   (|.ksetm "<A-->" ":b#<CR>")
   (|.ksetm "<A-r>" ":DzReload<CR>")
   (|.ksetm "<A-l>" #(launch-best-repl))
   (|.ksetm "<A-b>" #(snacks.picker.buffers))
   (|.ksetm "<A-g>" #(snacks.picker.grep))
   (|.ksetm "<A-f>" #(snacks.picker.files))
   (|.ksetm "<A-a>" #(snacks.picker.lines))
   (|.ksetm "<A-c>" #(snacks.picker.grep_word))
   (|.ksetm "<A-e>" #(snacks.picker.diagnostics_buffer))
   (|.ksetm "<CA-Left>" #(paredit.api.drag_element_backwards))
   (|.ksetm "<CA-Right>" #(paredit.api.drag_element_forwards))
   (|.ksetm "<A-Left>" #(paredit.api.drag_form_backwards))
   (|.ksetm "<A-Right>" #(paredit.api.drag_form_forwards))
   (|.ksetm "<C-Left>"
            #(|.til-moved!! #(paredit.api.move_to_prev_element_head)
                            #(do
                               (|.pcursor!)
                               (while (and (|.form-boundary?) (|.pcursor!)))
                               (paredit.api.move_to_prev_element_head))))
   (|.ksetm "<C-Right>"
            #(if (|.form-boundary?)
                 (while (and (|.form-boundary?) (|.ncursor!)))
                 (|.til-moved!! #(paredit.api.move_to_next_element_head)
                                #(do
                                   (|.ncursor!)
                                   (while (and (|.form-end?) (|.ncursor!)))))))
   (|.ksetm "<A-d>" #(paredit.api.delete_form))
   (|.ksetm "<A-x>" #(paredit.api.delete_element))
   (|.ksetm "<A-9>" #(paredit.api.slurp_backwards))
   (|.ksetm "<A-0>" #(paredit.api.slurp_forwards))
   (|.ksetm "<A-,>" #(paredit.api.barf_forwards))
   (|.ksetm "<A-.>" #(paredit.api.barf_backwards)))

 (fn setup-paredit []
   (setup-plugin :nvim-paredit {:use_default_keys true :indent {:enabled true}}))

 (fn setup-neovide []
   (kset "n" "<sc-t>"
         ":lua require(\"snacks\").terminal(\"fish\", {env={DZ_FISH_SKIP_FASTFETCH=\"yes\"}})<CR>")
   (kset "n" "<sc-s>" ":w<CR>")
   (kset "v" "<sc-c>" "\"+y")
   (kset "n" "<sc-v>" "\"+P")
   (kset "v" "<sc-v>" "\"+P")
   (kset "c" "<sc-v>" "<C-R>+")
   (kset "i" "<sc-v>" "<C-R>+"))

 (fn setup-orgmode []
   (doto (require :orgmode.config)
     (: :extend {})
     (: :install_grammar))
   (setup-plugin :orgmode
                 {:org_agenda_files "~/.org/**/*"
                  :org_default_notes_files "~/.org/index.org"
                  :org_hide_leading_stars false
                  :org_startup_indented true
                  :org_startup_folded :overview
                  :org_blank_before_new_entry {:heading false
                                               :plain_list_item false}})
   (->> {:pattern :org
         :callback #(vim.keymap.set :i "<S-CR>"
                                    "<cmd>lua require(\"orgmode\").action(\"org_mappings.meta_return\")<CR>"
                                    {:silent true :buffer true})}
        (vim.api.nvim_create_autocmd :FileType)))

 (import rainbow-delimiters)

 (fn setup-rainbow-delimiters []
   (setup-plugin :rainbow-delimiters.setup
                 {:query {"" :rainbow-delimiters :lua :rainbow-blocks}
                  :strategy {"" rainbow-delimiters.strategy.global
                             :vim rainbow-delimiters.strategy.local}
                  :highlight [:RainbowDelimiterBlue
                              :RainbowDelimiterViolet
                              :RainbowDelimiterOrange
                              :RainbowDelimiterGreen
                              :RainbowDelimiterCyan
                              :RainbowDelimiterRed
                              :RainbowDelimiterYellow]}))

 (fn setup-autopairs []
   (setup-plugin :nvim-autopairs {:enable_check_bracket_line false}))

 (fn setup-lualine []
   (setup-plugin :nvim-navic {:lsp {:auto_attach true}})
   (->> {:options {:icons_enabled true
                   :theme :auto
                   :component_separators {:left "" :right ""}
                   :section_separators {:left "" :right ""}
                   :disabled_filetypes {:statusline {} :winbar {}}
                   :ignore_focus {}
                   :always_divide_middle true
                   :always_show_tabline true
                   :globalstatus false
                   :refresh {:statusline 100 :tabline 100 :winbar 100}}
         :sections {:lualine_a [:mode]
                    :lualine_b [:branch :diff :diagnostics]
                    :lualine_c [:filename :lsp_progress :navic]
                    :lualine_x [:encoding :fileformat :filetype]
                    :lualine_y [:progress]
                    :lualine_z [:location]}
         :inactive_sections {:lualine_a []
                             :lualine_b []
                             :lualine_c [:filename]
                             :lualine_x [:location]
                             :lualine_y []
                             :lualine_z []}
         :tabline {}
         :winbar {}
         :inactive_winbar {}
         :extensions {}}
        (setup-plugin :lualine)))

 (fn setup-tidy []
   (setup-plugin :tidy {:filetype_exclude [:markdown :diff :org]}))

 (fn setup-snacks []
   (->> {:lazygit {:configure false}
         :bigfile {:enabled false}
         :dashboard {:enabled true
                     :sections [{:enabled true
                                 :pane 2
                                 :icon "         "
                                 :title "mitch nvim"
                                 :section :terminal
                                 :cmd "sleep 60"
                                 :padding 0
                                 :height 1
                                 :indent 0}
                                {:section :keys :gap 0 :padding 1}
                                {:pane 2
                                 :icon " "
                                 :title "Recent Files"
                                 :section :recent_files
                                 :indent 2
                                 :padding 1}
                                {:pane 2
                                 :icon " "
                                 :title :Projects
                                 :section :projects
                                 :indent 2
                                 :padding 1}
                                {:pane 2
                                 :icon " "
                                 :title "Git Status"
                                 :section :terminal
                                 :enabled #(not= nil (snacks.git.get_root))
                                 :cmd "git status --short --branch --renames"
                                 :padding 1
                                 :ttl (* 5 60)
                                 :indent 3}
                                {:pane 2
                                 :section :terminal
                                 :enabled true
                                 :cmd "echo 'write good code plzzz' | rustmon say; sleep 60"
                                 :height 24
                                 :padding 0
                                 :ttl (* 5 60)
                                 :indent 0}]}
         :explorer {:enabled true}
         :indent {:enabled true
                  :indent {:enabled false
                           :only_scope true
                           :hl [:SnacksIndent1
                                :SnacksIndent2
                                :SnacksIndent3
                                :SnacksIndent4
                                :SnacksIndent5
                                :SnacksIndent6
                                :SnacksIndent7
                                :SnacksIndent8]}
                  :scope {:enabled true
                          :siblings false
                          :edge false
                          :priority 200
                          :char "│"
                          :underline false
                          :only_current false
                          :hl [:SnacksIndent1
                               :SnacksIndent2
                               :SnacksIndent3
                               :SnacksIndent4
                               :SnacksIndent5
                               :SnacksIndent6
                               :SnacksIndent7
                               :SnacksIndent8]}
                  :chunk {:enabled true
                          :only_current false
                          :priority 200
                          :char {:corner_top "╭"
                                 :corner_bottom "╰"
                                 :horizontal "─"
                                 :vertical "│"
                                 :arrow ">"}
                          :hl [:SnacksIndent8
                               :SnacksIndent1
                               :SnacksIndent2
                               :SnacksIndent3
                               :SnacksIndent4
                               :SnacksIndent5
                               :SnacksIndent6
                               :SnacksIndent7]}}
         :input {:enabled true}
         :picker {:enabled true}
         :notifier {:enabled true}
         :quickfile {:enabled true}
         :scope {:enabled true :treesitter {:enabled true}}
         :scroll {:enabled true}
         :statuscolumn {:enabled true}
         :words {:enabled true}}
        (setup-plugin :snacks)))

 (loc aucmd #(vim.api.nvim_create_autocmd $...))
 (loc ucmd #(vim.api.nvim_create_user_command $...))

 (fn setup-treesitter []
   (setup-plugin :nvim-treesitter.config
                 {:incremental_selection {:enable true}
                  :indent {:enable true}
                  :fold {:enable true}})
   (_.L ts-enabled
        {:hl [:fennel :rust :javascript :typescript :lua :org]
         :fold [:fennel :rust :javascript :typescript :lua :org]
         :indent [:rust :javascript :typescript :lua]})
   (aucmd :FileType {:pattern ts-enabled.hl :callback #(vim.treesitter.start)})
   (aucmd :FileType
          {:pattern ts-enabled.fold
           :callback #(let [winopts (. vim.wo 0 0)]
                        (set winopts.foldexpr "v:lua.vim.treesitter.foldexpr()")
                        (set winopts.foldmethod :expr))})
   (aucmd :FileType
          {:pattern ts-enabled.indent
           :callback #(set vim.bo.indentexpr
                           "v:lua.require'nvim-treesitter'.indentexpr()")}))

 (fn setup-lsp []
   (fn lsp-enable [lsp-name cfg]
     (vim.lsp.config lsp-name (or cfg (. vim.lsp.config lsp-name) {}))
     (vim.lsp.enable lsp-name))

   (lsp-enable :rust_analyzer
               {:cmd [:rust-analyzer]
                :filetypes [:rust]
                :single_file_support true
                :root_markers [:Cargo.toml]
                :capabilities {:experimental {:serverStatusNotification true}}
                :before_init #(when (and $2.settings $2.settings.rust-analyzer)
                                (set $1.initializationOptions
                                     $2.settings.rust-analyzer))})
   (lsp-enable :fennel_ls
               {:cmd [:fennel-ls]
                :filetypes [:fennel]
                :root_markers [:flsproject.fnl]
                :single_file_support true
                :autostart true
                :capabilities {:offsetEncoding [:utf-8 :utf-16]}})
   (lsp-enable :ts_ls)
   (lsp-enable :lua_ls {:cmd [:lua-language-server]
                        :filetypes [:lua]
                        :autostart true
                        :single_file_support true
                        :log_level vim.lsp.protocol.MessageType.Warning
                        :root_markers [:.luarc.json
                                       :.luarc.jsonc
                                       :.luacheckrc
                                       :.stylua.toml
                                       :stylua.toml
                                       :selene.toml
                                       :selene.yml
                                       :.git]}))

 (import conform)

 (fn setup-conform []
   (conform.setup {:format_on_save true :formatters_by_ft {:fennel [:fnlfmt]}}))

 (import hooks :ibl.hooks)
 (import ibl)

 (fn setup-ibl []
   (fn hl [name] {:fg (Thm.faint-fg-of name)})

   (fn set-hl []
     (doto vim.api
       (_.|| :nvim_set_hl & 0 :iblz1 (hl :cyan))
       (_.|| :nvim_set_hl & 0 :iblz2 (hl :amber))
       (_.|| :nvim_set_hl & 0 :iblz3 (hl :magenta))
       (_.|| :nvim_set_hl & 0 :iblz4 (hl :green))
       (_.|| :nvim_set_hl & 0 :iblz5 (hl :orange))
       (_.|| :nvim_set_hl & 0 :iblz6 (hl :indigo))
       (_.|| :nvim_set_hl & 0 :iblz7 (hl :lime))
       (_.|| :nvim_set_hl & 0 :iblz8 (hl :red))))

   (hooks.register hooks.type.HIGHLIGHT_SETUP set-hl)
   (set-hl)
   (_.L hl-list [:iblz1 :iblz2 :iblz3 :iblz4 :iblz5 :iblz6 :iblz7 :iblz8])
   (ibl.setup {:indent {:char "" :highlight hl-list}
               :whitespace {:highlight hl-list :remove_blankline_trail true}
               :exclude {:filetypes [:org]}}))

 (fn do-configuration []
   (setup-vim-opts)
   (ucmd "DzColorscheme" (fn [] (pick-colorscheme)) {:nargs 0})
   (ucmd "DzReload"
         (fn [...]
           (comment (_.reload-modules!))
           (_.|| (require :nvim-config) :doTheThings)) {:nargs 0})
   (setup-treesitter)
   (setup-lsp)
   (setup-gitsigns)
   (setup-completion)
   (setup-paredit)
   (setup-orgmode)
   (setup-rainbow-delimiters)
   (setup-autopairs)
   (setup-lualine)
   (setup-tidy)
   (setup-snacks)
   (setup-conform)
   (add-colorschemes)
   (set-colorscheme :fluoromachine)
   (setup-ibl)
   (vim.api.nvim_clear_autocmds {:group :gitsigns :event [:ColorScheme]})
   (aucmd :ColorScheme {:callback on-colorscheme})
   (aucmd :BufLeave {:pattern "*.org" :callback #(vim.cmd "set list")})
   (aucmd :BufEnter {:pattern "*.org" :callback #(vim.cmd "set nolist")})
   (aucmd :BufLeave {:pattern "*.org" :callback #(snacks.indent.enable)})
   (aucmd :BufEnter {:pattern "*.org" :callback #(snacks.indent.disable)})
   (->> {:group (vim.api.nvim_create_augroup :LastPlace {:clear true})
         :pattern ["*"]
         :callback #(let [mark (vim.api.nvim_buf_get_mark 0 "\"")
                          lcount (vim.api.nvim_buf_line_count 0)]
                      (when (and (> (. mark 1) 0) (<= (. mark 1) lcount))
                        (pcall vim.api.nvim_win_set_cursor 0 mark)))}
        (vim.api.nvim_create_autocmd :BufReadPost))
   (when vim.g.neovide (setup-neovide))
   (setup-keymap))

 (exp do-configuration))
