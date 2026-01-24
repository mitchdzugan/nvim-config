(import-macros _ :__)

(_.module
 (import | :utils)
 (import LuaColor :lua-color)
 (loc HueClass (_.class :Hue))
 (loc SatClass (_.class :Sat))
 (loc VibClass (_.class :Vib))
 (loc ColorClass (_.class :Color))
 (loc Hue #(HueClass:new $...))
 (loc Sat #(SatClass:new $...))
 (loc Vib #(VibClass:new $...))
 (loc Color #(ColorClass:new $...))

 (fn ratio [BaseClass input]
   (if (and (_.subclass? input) (input:isInstanceOf BaseClass))
       input.ratio
       input))

 (fn VibClass.initialize [self input] (set self.ratio (ratio VibClass input)))

 (fn SatClass.initialize [self input] (set self.ratio (ratio SatClass input)))

 (fn HueClass.initialize [self input] (set self.ratio (ratio HueClass input)))

 (fn HueClass.bound [self ...]
   (Hue (|.bounder self ...)))

 (fn ColorClass.initialize [self ...]
   (set self.bold? false)
   (set self.c (LuaColor ...))
   (let [(h s v) (self.c:hsv)]
     (set self.h h)
     (set self.s s)
     (set self.v v)))

 (set ColorClass.h! #(let [h (Hue $2)] (Color {:h h.ratio :s $1.s :v $1.v})))
 (set ColorClass.h% #($1:h! ($2 $1.h)))
 (set ColorClass.s! #(let [s (Sat $2)] (Color {:h $1.h :s s.ratio :v $1.v})))
 (set ColorClass.s% #($1:s! ($2 $1.s)))
 (set ColorClass.v! #(let [v (Vib $2)] (Color {:h $1.h :s $1.s :v v.ratio})))
 (set ColorClass.v% #($1:v! ($2 $1.v)))

 (fn ColorClass.to-hl [self]
   {:fg (tostring self.c)})

 (fn bg-color []
   (let [hl-normal (vim.api.nvim_get_hl_by_name :Normal true)
         bg-decimal (or (. hl-normal :background) 0)]
     (LuaColor (string.format "#%06x" bg-decimal))))

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

 (fn hsv [h s v] (LuaColor {: h : s : v}))

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

 (fn pub.reset-theme []
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
     (tostring (_h! (to-fg Thm.bg 0.4) (h-of name))))))
