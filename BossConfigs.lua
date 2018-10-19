-- RaidSetup, Classic WoW raid setup AddOn
-- by thekk
-- 19.10.2018

RS_SetupDB = {
	Naxxramas = {
		Four_HM = {
			Grp1={"Tank","Tank","Paladin","Paladin","Warlock"},
			Grp2={"Tank","Tank","Paladin","Paladin","Warlock"},
			Grp3={"Tank","Tank","Paladin","Paladin","Warlock"},
			Grp4={"Tank","Tank","Paladin","Paladin","Warlock"},
			Grp5={"MeleeDD","MeleeDD","MeleeDD","Hunter","Heal"},
			Grp6={"MeleeDD","MeleeDD","MeleeDD","Hunter","Heal"},
			Grp7={"MeleeDD","MeleeDD","MeleeDD","Hunter","Heal"},
			Grp8={"MeleeDD","RangeDD","RangeDD","Hunter","Heal"},
			Tanks= {"Tank1","Tank2","Tank3","Tank4","Tank5","Tank6","Tank7","Tank8"},
			TankTargets={["Thane Korth'azz"]={"1","2"},
				["Lady Blaumeux"]={"3","4"},
				["Highlord Mograine"]={"5","6"},
				["Sir Zeliek"]={"7","8" }
			},
			Heals={"Heal1","Heal2","Heal3","Heal4","Heal5","Heal6","Heal7","Heal8","Heal9","Heal10","Heal11","Heal12"},
			HealTargets={
				{"1","2"},
				{"1","2"},
				{"3","4"},
				{"3","4"},
				{"5","6"},
				{"5","6"},
				{"7","8"},
				{"7","8"}
			},
			MeleeDD="10",
			RangeDD="10"
		},
	},
}