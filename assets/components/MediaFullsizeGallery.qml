// *************************************************** //
// Media Fullsize Gallery Component
//
// This component shows a fullsize gallery of media items
// with an optional text field.
// This component accepts data of type InstagramMediaData
//
// Author: Dirk Songuer
// License: GPL v2
// See: http://choosealicense.com/licenses/gpl-v2/
// *************************************************** //

// import blackberry components
import bb.cascades 1.2

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext

// import image url loader component
import WebImageView 1.0

Container {
    id: mediaFullsizeGalleryComponent

    // signal if gallery is scrolled to start or end
    signal listBottomReached()
    signal listTopReached()
    signal listIsScrolling()

    // property that holds the id of the next image
    // this is given by Instagram for easy pagination
    property string paginationNextMaxId: ""

    // property that holds the current index
    // this is incremented as new items are added
    // to the list a provides the order the items were
    // added to the data model
    property int currentItemIndex: 0

    // properties to define how the list should be sorted
    property string listSortingKey: "timestamp"
    property alias listSortAscending: mediaFullsizeGalleryDataModel.sortedAscending

    // signal to clear the gallery contents
    signal clearGallery()
    onClearGallery: {
        mediaFullsizeGalleryDataModel.clear();
    }

    // signal to add a new item
    // item is given as type InstagramMediaData
    signal addToGallery(variant item)
    onAddToGallery: {
        // console.log("# Adding item with ID " + item.mediaId + " of type " + item.mediaType + " to thumbnail list data model");
        mediaFullsizeGalleryComponent.currentItemIndex += 1;
        mediaFullsizeGalleryDataModel.insert({
                "mediaData": item,
                "timestamp": item.timestamp,
                "currentIndex": mediaFullsizeGalleryComponent.currentItemIndex
            });
    }

    // signal if item was clicked
    signal itemClicked(variant mediaData)

    // this is a workaround to make the signals visible inside the listview item scope
    // see here for details: http://supportforums.blackberry.com/t5/Cascades-Development/QML-Accessing-variables-defined-outside-a-list-component-from/m-p/1786265#M641
    onCreationCompleted: {
        Qt.fullDisplaySize = DisplayInfo.width;
    }

    // layout orientation
    layout: DockLayout {
    }

    // list of Instagram popular media
    ListView {
        id: mediaFullsizeGallery

        // associate the data model for the list view
        dataModel: mediaFullsizeGalleryDataModel

        // define snap mode so that on the q series
        // an image is always visible full screen
        snapMode: SnapMode.LeadingEdge

        // layout orientation
        layout: StackListLayout {
            orientation: LayoutOrientation.TopToBottom
        }

        // define component which will represent list item GUI appearence
        listItemComponents: [
            ListItemComponent {
                type: "item"

                // define gallery view component as view for each list item
                Container {
                    id: imageGalleryItem

                    // layout orientation
                    layout: DockLayout {
                    }

                    // item positioning
                    verticalAlignment: VerticalAlignment.Fill
                    horizontalAlignment: HorizontalAlignment.Fill

                    // item created time
                    property string itemCreatedTime: ListItemData.mediaData.createdTime

                    // the actual thumbnail image
                    InstagramImageView {
                        id: itemImage

                        // position and layout properties
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center

                        // set size, type and url
                        imageSize: Qt.fullDisplaySize
                        mediaType: ListItemData.mediaData.mediaType
                        url: ListItemData.mediaData.mediaStandardImage

                        // when image loading is done, set image description visibility to true
                        onLoadProgressChanged: {
                            if (loadProgress == 1) {
                                // check if user has liked the image
                                // if so, set confirmed state accordingly
                                if ((typeof ListItemData.mediaData !== "undefined") && (ListItemData.mediaData.userHasLiked == true)) {
                                    mediaDetailMediaDescription.confirmed = true;
                                } else {                                    
                                    mediaDetailMediaDescription.confirmed = false;
                                }

                                // show description
                                mediaDetailMediaDescription.visible = true;
                            }
                        }
                    }

                    // the image description
                    // this contains user profile image, name and image caption
                    MediaDescription {
                        id: mediaDetailMediaDescription

                        // layout definition
                        verticalAlignment: VerticalAlignment.Bottom
                        preferredWidth: Qt.fullDisplaySize
                        minWidth: Qt.fullDisplaySize

                        // image description (profile picture, name and image description)
                        userimage: ListItemData.mediaData.userData.profilePicture
                        username: ListItemData.mediaData.userData.username
                        imagecaption: ListItemData.mediaData.caption

                        // show only one line of the caption
                        captionMultiline: false

                        // set initial visibility to hidden
                        // will be set visible when the image loading is done
                        visible: false

                        // very faint transparency
                        opacity: 0.97
                    }

                    // bottom spacer
                    Container {
                        // layout definition
                        verticalAlignment: VerticalAlignment.Bottom
                        preferredWidth: Qt.fullDisplaySize
                        minWidth: Qt.fullDisplaySize
                        preferredHeight: 5
                        maxHeight: 5

                        // set initial background color
                        background: Color.create(Globals.instagoConfirmedBackgroundColor)
                    }

                    // tap handling
                    // if item is tapped, change opacity
                    ListItem.onActivationChanged: {
                        if (active) {
                            // set opacity to transparent, image wil lfade into the background
                            itemImage.opacity = 0.5;

                            // set size so that image gets smaller on press
                            itemImage.imageSize = Qt.fullDisplaySize - 5;
                        } else {
                            // reset opacity to normal
                            itemImage.opacity = 1.0;

                            // set size so that image resets to normal on release
                            itemImage.imageSize = Qt.fullDisplaySize;
                        }
                    }
                }
            }
        ]

        // add action for tap on item
        onTriggered: {
            var currentItemData = mediaFullsizeGalleryDataModel.data(indexPath);

            // send item clicked event
            mediaFullsizeGalleryComponent.itemClicked(currentItemData.mediaData);
        }

        // add action for loading additional data after scrolling to bottom
        attachedObjects: [
            ListScrollStateHandler {
                id: scrollStateHandler
                onAtBeginningChanged: {
                    // console.log("# onAtBeginningChanged");
                    if (scrollStateHandler.atBeginning) {
                        mediaFullsizeGalleryComponent.listTopReached();
                    }
                }
                onAtEndChanged: {
                    // console.log("# onAtEndChanged");
                    if (scrollStateHandler.atEnd) {
                        mediaFullsizeGalleryComponent.listBottomReached();
                    }
                }
                onScrollingChanged: {
                    // console.log("# List is scrolling: " + scrollStateHandler.toDebugString());
                    if (! scrollStateHandler.atBeginning) {
                        mediaFullsizeGalleryComponent.listIsScrolling();
                    }
                }
            }
        ]
    }

    // attached objects
    attachedObjects: [
        // this will be the data model for the popular media list view
        GroupDataModel {
            id: mediaFullsizeGalleryDataModel
            sortedAscending: false
            sortingKeys: [ listSortingKey ]

            // items are grouped by the view and transformators
            // no need to set a behaviour by the data model
            grouping: ItemGrouping.None
        }
    ]
}
