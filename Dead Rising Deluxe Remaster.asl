//Dead Rising Deluxe Remaster Autosplitter Version 1.0 (20/09/24)
//Created by TheDementedSalad

//Special thanks to creators and testers:
//Ecdycis - Went through the game and showed event numbers for me to jot down


//TheDementedSalad - Created the splitter 
//Ero - ASL helper

state("DRDR"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.Settings.CreateFromXml("Components/DRDR.Settings.xml");
}

init
{
	IntPtr EventTimelineManager = vars.Helper.ScanRel(3, "48 8b 0d ???????? 83 79 ???? 74 ?? 8b 43");
	IntPtr AreaManager = vars.Helper.ScanRel(3, "48 8b 05 ???????? 81 b8 ???????????????? 74 ?? 48 8b 83");
	IntPtr PlayerStatusManager = vars.Helper.ScanRel(3, "48 8b 15 ???????? 48 8b cf 44 89 74 24");
	IntPtr SoundFlowStateManager = vars.Helper.ScanRel(3, "48 8b 05 ???????? 83 78 ???? 0f 84 ???????? 48 8b 05");
	
	//_CurrentChapter
	vars.Helper["CurrentEvent"] = vars.Helper.Make<short>(EventTimelineManager, 0x78);
	vars.Helper["IsLoadingLevel"] = vars.Helper.Make<bool>(AreaManager, 0x15C);
	
	vars.Helper["SoundFlow"] = vars.Helper.Make<int>(SoundFlowStateManager, 0x70);
	
	vars.Helper["AreaStageIndex"] = vars.Helper.Make<short>(PlayerStatusManager, 0xA8, 0x60, 0x10);
	vars.Helper["AreaNoIndex"] = vars.Helper.Make<short>(PlayerStatusManager, 0xA8, 0x60, 0x12);
	vars.Helper["RoomNo"] = vars.Helper.Make<short>(PlayerStatusManager, 0xA8, 0x60, 0x14);
	vars.Helper["RoomIndex"] = vars.Helper.Make<short>(PlayerStatusManager, 0xA8, 0x60, 0x16);
	
	vars.completedSplits = new HashSet<string>();
}

update
{
	//print(modules.First().ModuleMemorySize.ToString());
	
	vars.Helper.Update();
	vars.Helper.MapPointers();
}

onStart
{
	vars.completedSplits.Clear();
	timer.IsGameTimePaused = true;
}

start
{	
	return current.AreaStageIndex == 1 && current.AreaNoIndex == 31 && current.RoomNo == 309 && old.SoundFlow == 9;
}

split
{
	string setting = "";
	
	if (current.CurrentEvent != old.CurrentEvent && current.CurrentEvent != -1){
		setting = "Event_" + current.CurrentEvent;
	}
	
	// Debug. Comment out before release.
	if (!string.IsNullOrEmpty(setting))
	vars.Log(setting);

	if (settings.ContainsKey(setting) && settings[setting] && vars.completedSplits.Add(setting)){
		return true;
	}
}

isLoading
{
	return current.IsLoadingLevel || current.CurrentEvent != -1 || current.SoundFlow == 9 || current.SoundFlow == 1;
}

reset
{
	return current.CurrentEvent == 258 && old.CurrentEvent == -1;
}