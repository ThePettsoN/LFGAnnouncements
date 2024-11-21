local WOW_API_CONSTANTS = {
	read_globals = {
		"WOW_PROJECT_MAINLINE",
		"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
		"WOW_PROJECT_WRATH_CLASSIC",
		"WOW_PROJECT_CATACLYSM_CLASSIC",
		"WOW_PROJECT_ID",
	},
}

local WOW_API_NAMESPACES = {
	read_globals = {
		C_AddOns = {
			fields = {
				"DisableAddOn",
				"DisableAllAddOns",
				"DoesAddOnExist",
				"EnableAddOn",
				"EnableAllAddOns",
				"GetAddOnDependencies",
				"GetAddOnEnableState",
				"GetAddOnInfo",
				"GetAddOnMetadata",
				"GetAddOnOptionalDependencies",
				"GetNumAddOns",
				"GetScriptsDisallowedForBeta",
				"IsAddOnLoadable",
				"IsAddOnLoaded",
				"IsAddOnLoadOnDemand",
				"IsAddonVersionCheckEnabled",
				"LoadAddOn",
				"ResetAddOns",
				"ResetDisabledAddOns",
				"SaveAddOns",
				"SetAddonVersionCheck",
			},
		},
		C_Engraving = {
			fields = {
				"AddCategoryFilter",
				"AddExclusiveCategoryFilter",
				"CastRune",
				"ClearAllCategoryFilters",
				"ClearCategoryFilter",
				"ClearExclusiveCategoryFilter",
				"EnableEquippedFilter",
				"GetCurrentRuneCast",
				"GetEngravingModeEnabled",
				"GetExclusiveCategoryFilter",
				"GetNumRunesKnown",
				"GetRuneCategories",
				"GetRuneForEquipmentSlot",
				"GetRuneForInventorySlot",
				"GetRunesForCategory",
				"HasCategoryFilter",
				"IsEngravingEnabled",
				"IsEquipmentSlotEngravable",
				"IsEquippedFilterEnabled",
				"IsInventorySlotEngravable",
				"IsInventorySlotEngravableByCurrentRuneCast",
				"IsKnownRuneSpell",
				"IsRuneEquipped",
				"RefreshRunesList",
				"SetEngravingModeEnabled",
				"SetSearchFilter",
			}
		},
		C_GameRules = {
			fields = {
				"IsHardcoreActive",
				"IsSelfFoundAllowed",
			},
		},
	},
}

local WOW_LIBS = {
	read_globals = {
		bit = {
			fields = {
				"bnot",
				"band",
				"bor",
				"bxor",
				"lshift",
				"rshift",
				"arshift",
				"mod",
			},
		},
		math = {
			fields = {
				"abs",
				"acos",
				"asin",
				"atan",
				"atan2",
				"ceil",
				"cos",
				"deg",
				"exp",
				"floor",
				"frexp",
				"ldexp",
				"log",
				"log10",
				"max",
				"min",
				"mod",
				"read_globalsrandom",
				"sin",
				"sqrt",
				"tan",
			}
		},
		string = {
			fields = {
				"strlenutf8",
				"strcmputf8i",
				"strtrim",
				"strsplit",
				"strjoin",
				"strconcat",
				"tostringall",
			}
		},
		table = {
			fields = {
				"setn",
				"removemulti",
				"contains",
				"wipe",

			}
		}
	},
}

local WOW_API_FUNCTIONS = {
	read_globals = {
		"GetBuildInfo",
		"GetAddOnInfo",
		"IsAddOnLoaded",
		"CreateFrame",
		"strmatch",
		"CopyTable",
	},
}

local LIBS = {
	read_globals = {
		LibStub = {
			fields = {
				"NewLibrary",
				"GetLibrary",
				"IterateLibraries",
			}
		},
		BigWigs = {
			fields = {
				"GetBossModule",
			}
		},
		PUtils = {
			fields = {
				PATCH = {},
				debug = {
					fields = {
						"initialize",
						"initializeModule",
					},
				},
				game = {
					fields = {
						"GameVersionLookup",
						"GameExpansionLookup",
						"getGameVersion",
						"getGameExpansion",
						"compareGameVersion",
						"ClassIds",
						"ShapeshiftIds",
						"ItemRarity",
					},
				},
				string = {
					fields = {
						"printf",
						"uuid",
						"indent",
					},
				},
				table = {
					fields = {
						"mergeRecursive",
						"find",
						"createLookup",
						"dump",
						"clone",
						"keys",
						"values",
					},
				},
			},
		},
	},
}

stds.wow_api_constants = WOW_API_CONSTANTS
stds.wow_api_namespaces = WOW_API_NAMESPACES
stds.wow_api_functions = WOW_API_FUNCTIONS
stds.wow_libs = WOW_LIBS
stds.libs = LIBS


local base_config = {
	std = "lua51+wow_api_constants+wow_api_namespaces+wow_api_functions+wow_libs+libs",
	self = false,
	ignore = {
		"631",
	}
}

files["*"] = base_config