
function drawBenchmark(Menu, page)
    UiColor(Menu.textMutedColor)
    UiFont("regular.ttf", 16)
    UiText("Settings for " .. page.label .. " will appear here.")

    UiTranslate(0, 40)

    if UiTextButton("Test") then
        StartLevel("benchmark", "BUILT-IN/../../mods/castle/main.xml")
    end
end
