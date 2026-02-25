(import-macros __ :__)

(__.module (fn pub.hl [...] (vim.api.nvim_set_hl 0 ...))
  (import snacks)
  (pub- Snk snacks)

  (fn pub.lines [s e]
    (vim.api.nvim_buf_get_lines 0 s e false))

  (fn pub.line [nth]
    (if (_.nil? nth)
        (vim.api.nvim_get_current_line)
        (. (lines (_.dec nth) nth) 1)))

  (fn pub.cursor [_id ...]
    (let [id (or _id 0)]
      (vim.api.nvim_win_get_cursor id ...)))

  (fn pub.cursor! [pos _id ...]
    (let [id (or _id 0)]
      (vim.api.nvim_win_set_cursor id pos ...)))

  (fn pub.til-moved!! [...]
    (let [fns [...]
          [r1 c1] (cursor)
          unchanged? #(let [[rn cn] (cursor)] (and (= r1 rn) (= c1 cn)))]
      (each [_ f (pairs fns) &until (not (unchanged?))]
        (f r1 c1))
      (not (unchanged?))))

  (fn pub.til-moved! [...]
    (let [fns [...]]
      (til-moved!! (_.unpack (icollect [_ f (ipairs fns)]
                               #(pcall cursor! (f $...)))))))

  (fn pub.ncursor! []
    (til-moved! #[$1 (_.inc $2)] #[(_.inc $1) 0]))

  (fn pub.pcursor! []
    (til-moved! #[$1 (_.dec $2)] #[(_.dec $1) (length (line (_.dec $1)))]))

  (fn pub.char []
    (let [[_ c] (cursor)]
      (: (line) :sub (_.inc c) (_.inc c))))

  (loc end-chars {")" true "}" true "]" true})
  (loc start-chars {"(" true "{" true "[" true "#" true})
  (loc boundary-chars (_.assign {} end-chars start-chars))

  (fn pub.form-end? []
    (let [c (char)] (or (string.match c "%s") (. end-chars c))))

  (fn pub.form-start? []
    (. start-chars (char)))

  (fn pub.form-boundary? []
    (let [c (char)] (or (string.match c "%s") (. boundary-chars c))))

  (fn pub.dbg [...] (snacks.debug.inspect ...))

  (fn pub.bounder [_l __h]
    (let [_h (if (_.nil? __h) (- 1 _l) __h)
          l (math.min _l _h)
          h (math.max _l _h)]
      #(math.max l (math.min $1 h))))

  (fn pub.limr [l] (bounder l (- 1 l)))

  (fn pub.kset [modes lhs rhs opts]
    (vim.keymap.set modes lhs rhs (_.assign {:noremap true} (or opts {}))))

  (pub- ksetm #(kset [:n :v] $...))
  (pub- ksetn #(kset [:n] $...))
  (pub- ksetv #(kset [:v] $...))

  (fn pub.km [in-title ...]
    (let [title (.. in-title "       ␛ to return to buffer")
          keys (icollect [_ [key desc action icon] (ipairs [...])]
                 {: key : desc : action : icon})]
      (snacks.dashboard {:preset {: keys} :sections [{:section :keys : title}]})))

  (pub- aucmd #(vim.api.nvim_create_autocmd $...))
  (pub- ucmd #(vim.api.nvim_create_user_command $...)))
