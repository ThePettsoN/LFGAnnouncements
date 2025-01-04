local _, tbl = ...
local LocaleStrings = {
    options_general_header = "General",
    options_general_duration_name = "Duration, in seconds, each request should be visible",

    options_general_enable_in_areas_header = "Enable addon in areas",
    options_general_enable_in_areas_world = "World",
    options_general_enable_in_areas_party = "Dungeons",
    options_general_enable_in_areas_raid = "Raids",
    options_general_enable_in_areas_arena = "Arenas",
    options_general_enable_in_areas_pvp = "Battlegrounds",

    options_general_msg_formatting_header = "Messages Formatting",
    options_general_msg_formatting_font_name = "Font",
    options_general_msg_formatting_size_name = "Size",
    options_general_msg_formatting_raid_marker_filter_name = "Remove raid markers from messages",
    options_general_msg_formatting_show_total_time_name = "Show the total time instead of current time since last request",
    options_general_msg_formatting_show_level_range_name = "Show the level range for each instance type",

    options_general_minimap_header = "Minimap",
    options_general_minimap_visible_name = "Show minimap button",
    options_general_minimap_locked_name = "Lock minimap button",

    options_notifications_header = "Notifications",
    options_notifications_sound_header = "Sound",
    options_notifications_sound_enabled_name = "Play sound on new requests",
    options_notifications_sound_sound_id_name = "Sound To Play",
    options_notifications_sound_play_sound_name = "Play",
    options_notifications_sound_default = "Default",
    options_notifications_sound_voice_chat_join_channel = "VoiceChat - Join Channel",
    options_notifications_sound_ingame_store_purchase_delivered = "InGame Store - Purchase Delivered",

    options_notifications_toaster_header = "Toaster",
    options_notifications_toaster_enabled_name = "Show a toast window on new requests",
    options_notifications_toaster_collapse_other_name = "Collapse other categories when opening request",
    options_notifications_toaster_duration_name = "Duration, in seconds, the toaster should be visible",
    options_notifications_toaster_width_name = "Width",
    options_notifications_toaster_height_name = "Height",
    options_notifications_toaster_num_toasters_name = "Number of toasters that can be shown at once",

    options_notifications_flash_icon_header = "Flash Client Icon",
    options_notifications_flash_icon_enabled_name = "Flash the client game icon on new requests",
    options_notifications_show_in_areas_header = "Show notifications in areas",

    options_filters_header = "Filters",
    options_filters_enable_all_btn = "Enable All",
    options_filters_disable_all_btn = "Disable All",
    options_filters_difficulty_filter_name = "Filter on dungeon difficulty",
    options_filters_difficulty_filter_desc = "Only show dungeons with the matched difficulty. Raids will always be shown.",
    options_filters_difficulty_all = "Show All",
    options_filters_difficulty_normal = "Normal Only",
    options_filters_difficulty_heroic = "Heroic Only",
    options_filters_boost_filter_name = "Filter boost requests",
    options_filters_boost_filter_desc = "Try filter requests where people are selling or promoting boost runs.",
    options_filters_gdkp_filter_name = "Filter gdkp requests",
    options_filters_gdkp_filter_desc = "Try filter gdkp runs.",
    options_filters_lfg_filter_name = "Filter LFG requests",
    options_filters_lfg_filter_desc = "Try filter LFG runs.",
    options_filters_lfm_filter_name = "Filter LFM requests",
    options_filters_lfm_filter_desc = "Try filter LFM runs.",
    options_filters_fake_filter_amount_name = "Filter requests with more than %d matched instances from a message",
    options_filters_fake_filter_amount_desc = "Recommended to leave this a bit higher than desired due to false results (\"MT\" could mean \"Main Tank\" but would also trigger a hit for Mana-Tombs).",

    options_filters_custom_tag_new_header = "New",
    options_filters_custom_tag_name_name = "Name",
    options_filters_custom_tag_tags_name = "Tags",
    options_filters_custom_tag_desc = "Custom tags separated by spaces",
    options_filters_custom_tag_remove_btn = "Remove",
    options_filters_custom_tag_add_btn = "Add",

    options_filters_vanilla_dungeons_name = "Vanilla Dungeons",
    options_filters_vanilla_raids_name = "Vanilla Raids",
    options_filters_tbc_vanilla_dungeons_name = "TBC Dungeons",
    options_filters_tbc_raids_name = "TBC Dungeons",
    options_filters_wotlk_dungeons_name = "WotLK Dungeons",
    options_filters_wotlk_raids_name = "WotLK Dungeons",
    options_filters_cataclysm_dungeons_name = "Cataclysm Dungeons",
    options_filters_cataclysm_raids_name = "Cataclysm Dungeons",
    options_filters_custom_name = "Custom",

    entry_context_menu_who_name = "Who",
    entry_context_menu_whisper_name = "Whisper",
    entry_context_menu_invite_name = "Invite",
    entry_context_menu_ignore_name = "Ignore",
    entry_context_menu_copy_url_name = "Copy URL",
    entry_context_menu_copy_armory_name = "Copy Armory URL",
    entry_context_menu_who = "Who %s",
    entry_context_menu_whisper = "Whisper %s",
    entry_context_menu_invite = "Invite %s",
    entry_context_menu_ignore = "Ignore %s",


    ui_settings_btn = "Settings",
    ui_close_btn = "Close",
}

tbl.LocaleStrings = LocaleStrings
tbl.Localize = function(key, arg1, ...)
    local str = LocaleStrings[key]
    if not str then
        error("Failed to localize string ", str)
        return str
    end

    if arg1 then
        return string.format(str, arg1, ...)
    end

    return str
end