iOS app structure:

- Main View is the Map view.
	- Map talks to controller for zoom/center adjustments sent from various views.
- Map is overlaid with a Sheet containing the Tab view.
	- All sheets have interactive dismiss disabled.
	- Each sheet has it's own presentation detents (more/less map visible).
- Tab view is contained within the sheet, standard Tab layout otherwise.


https://www.staticforms.xyz
cac5c2ad-10e9-468b-aa78-73a4def62bde

