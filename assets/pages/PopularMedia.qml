// *************************************************** //
// Popular Photos Page
//
// The popular photos page shows a grid of the current
// popular photos that can be tapped.
// It is shown as default starting page if the user is
// not logged in.
// *************************************************** //

// import blackberry components
import bb.cascades 1.2

// set import directory for components
import "../components"

// shared js files
import "../global/globals.js" as Globals
import "../global/copytext.js" as Copytext
import "../instagramapi/media.js" as MediaRepository

// this is a page that is available from the main tab, thus it has to be a navigation pane
// note that the id is always "navigationPane"
NavigationPane {
    id: navigationPane

    Page {
        id: popularMediaPage

        // signal if popular media data loading is complete
        signal popularMediaDataLoaded(variant mediaDataArray)

        // signal if popular media data loading encountered an error
        signal popularMediaDataError(variant errorData)

        titleBar: TitleBar {
            title: Copytext.instagoTitlePopular
        }

        // main content container
        Container {
            // layout definition
            layout: DockLayout {
            }

            // layout definition
            topPadding: 1
            bottomPadding: 1

            ThumbnailGallery {
                id: popularMediaThumbnails                
            }

            LoadingIndicator {
                id: loadingIndicator
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }

            ErrorMessage {
                id: errorMessage
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
            }
        }

        // page creation is finished
        // load the gallery content as soon as the page is ready
        onCreationCompleted: {
            // console.log("# Creation of popular media page finished");

            // show loader
            loadingIndicator.showLoader("Loading popular items");

            // load popular media stream
            MediaRepository.getPopularMedia(popularMediaPage);
        }

        // popular media data loaded and transformed
        // data is stored in "mediaDataArray" variant as array of type InstagramMediaData
        onPopularMediaDataLoaded: {
            // console.log("# Popular media data loaded. Found " + mediaDataArray.length + " items");

            // iterate through data objects
            for (var index in mediaDataArray) {
                popularMediaThumbnails.addToGallery(mediaDataArray[index]);
            }

            // hide loader
            loadingIndicator.hideLoader();
        }
    }

    // destroy pages after use
    onPopTransitionEnded: {
        page.destroy();
    }
}