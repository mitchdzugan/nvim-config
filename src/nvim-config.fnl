(import-macros _ :__)

(local ENV #(os.getenv (.. :DZ_NVIM_CONFIG_ $1)))

(var initialized? false)

(fn C [MOD]
  ((. (or MOD (require :do-configuration)) :exports)))

(fn L []
  (when (not initialized?)
    (set initialized? true))
  (_.reload-modules!)
  (let [fennel (_.|| (require :fennel) :install)]
    (set fennel.path (ENV :FENNEL_PATH))
    (set fennel.macro-path (ENV :MACRO_PATH))
    (set package.path (.. (ENV :LUA_PATH_EXTRA) package.path))
    (let [p (.. (ENV :CHECKOUT_PATH) "/src/do-configuration.fnl")]
      (C (fennel.dofile p)))))

{:doTheThings #(if (= :yes (ENV :USE_LOCAL)) (L) (C))}
