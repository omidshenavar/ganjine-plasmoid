# Ganjine Plasmoid

A KDE Plasma widget that displays random Persian poems from [ganjoor.net](http://ganjoor.net). This widget was originally created as a Cinnamon desklet by Mohammad S. (mohammad-sn) and has been ported to KDE Plasma by Omid Shenavar.

## Features
- Displays random Persian poems on your desktop.
- Configurable refresh interval to fetch new poems.
- Option to limit poems to a specific poet.
- Customizable appearance: font, text color, background color, and opacity.
- History navigation to view previous poems.
- Copy poem text or link to clipboard.
- Open poem source link in a web browser.

## Screenshots

![Ganjine Widget in Action](images/Screenshot.png)

*Screenshot of the Ganjine widget displaying a Persian poem on the desktop.*

## Installation

### Requirements
- KDE Plasma 6.0 or later.
- Internet connection to fetch poems from ganjoor.net.

### Download
Download the latest version from the [Releases page](https://github.com/omidshenavar/ganjine-plasmoid/releases) or [KDE Store](https://store.kde.org/p/2280314).

### Install via Source
1. Clone the repository:
    ```bash
    git clone https://github.com/omidshenavar/ganjine-plasmoid.git
    cd ganjine-plasmoid
    ```

2. Zip it with:
    ```bash
    zip -r ganjine-plasmoid.plasmoid .
    ```

3. Add the widget to your desktop:
   - Right-click on your desktop.
   - Select "Add Widgets".
   - Click "Get New Widgets" and add the plasmoid from the local file you created in the previous step.

### Install via KDE Store
You can also install the widget directly from the KDE Store:
1. Open the "Add Widgets" menu in Plasma.
2. Click "Get New Widgets" > "Download New Plasma Widgets".
3. Search for "Ganjine" and install.

### Uninstall
To uninstall the widget, remove it from your desktop and delete the corresponding widget from the same location where it was installed.

### Customize
Right-click the widget and select "Configure Ganjine..." to customize:
- **Font:** Choose the desired font for poem text.
- **Font Size and Boldness:** Adjust the text size and boldness.
- **Text Color and Opacity:** Set the color and transparency of the poem text.
- **Background:** Enable a custom background with adjustable color and opacity.
- **Refresh Interval:** Set how often a new poem is fetched (in minutes).
- **Poet Selection:** Limit poems to a specific poet from the list.

## Known Issues
- **Text Overflow with Enlarged Font Size**

**Problem:** When increasing the poem's font size, the text may overflow outside the background.

**Workaround:** Manually resize the widget slightly in KDE edit mode after changing the font size to adjust the background properly.

## Authors

- **Mohammad S. (mohammad-sn)** - Original creator of the Cinnamon desklet.
- **Omid Shenavar** (shenavar.omid@gmail.com) - Ported to KDE Plasma.

## License

This project is licensed under the GPL-3.0+ License.

## Acknowledgments

- Original Cinnamon desklet: ganjine@mohammad-sn
- Poems sourced from [ganjoor.net](http://ganjoor.net)
