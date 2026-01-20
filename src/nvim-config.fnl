(import-macros _ :__)

(fn do-configuration [module] (module.do-configuration))

(fn runlocal []
  (_.reload-modules!)
  (let [fennel (require :fennel)]
    (set fennel.path (os.getenv :DZ_NVIM_CONFIG_FENNEL_PATH))
    (set fennel.macro-path (os.getenv :DZ_NVIM_CONFIG_MACRO_PATH))
    (set package.path (.. (os.getenv :DZ_NVIM_CONFIG_LUA_PATH_EXTRA)
                          package.path))
    (do-configuration (fennel.dofile (.. (os.getenv :DZ_NVIM_CONFIG_CHECKOUT_PATH)
                                         "/src/do-configuration.fnl")))))

(fn doTheThings []
  (if (= :yes (os.getenv :DZ_NVIM_CONFIG_USE_LOCAL))
      (runlocal)
      (do-configuration (require :do-configuration))))

{: doTheThings}
