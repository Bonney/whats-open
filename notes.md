iOS app structure:

- Main View is the Map view.
	- Map talks to controller for zoom/center adjustments sent from various views.
- Map is overlaid with a Sheet containing the Tab view.
	- All sheets have interactive dismiss disabled.
	- Each sheet has it's own presentation detents (more/less map visible).
- Tab view is contained within the sheet, standard Tab layout otherwise.
