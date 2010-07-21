#import <UIKit/UIKit.h>
#import "JSONAPIRequest.h"
#import "CalendarConstants.h"
#import "EventCategoriesTableView.h"
#import "EventListTableView.h"
#import "CalendarMapView.h"
#import "DatePickerViewController.h"

@class MITSearchEffects;
@class EventListTableView;
@class CalendarEventMapAnnotation;
@class DatePickerViewController;

@interface CalendarEventsViewController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, MKMapViewDelegate, JSONAPIDelegate, DatePickerViewControllerDelegate> {

	CalendarEventListType activeEventList; // today, browse, acad, holidays...
	NSDate *startDate;
	NSDate *endDate;
	NSArray *events;
	
	// views in the body
	UITableView *theTableView;
	CalendarMapView *theMapView;
	
	// views in the header
	UIScrollView *navScrollView;
	UISearchBar *theSearchBar;
	NSMutableArray *navButtons;
	UIButton *leftScrollButton;
	UIButton *rightScrollButton;
	
	UIView *datePicker;
	UIView *nothingFound;
	
	//DatePickerViewController *dateSelector;
	
	// search
	//UISearchDisplayController *searchController;
	MITSearchEffects *searchOverlay;
	UIView *loadingIndicator;
	// this is a tableview subclass but we're only using it for
	// its delegate methods
	EventListTableView *searchResultsTableView;
	CalendarMapView *searchResultsMapView;
	
	// category parameter for list of events in a category
	NSInteger theCatID;
	
	BOOL showList;
	BOOL showScroller;
	BOOL dateRangeDidChange;
	
	BOOL requestDispatched;
	BOOL categoriesRequestDispatched;
	JSONAPIRequest *apiRequest;
	
}

@property (nonatomic, assign) BOOL showScroller;
@property (nonatomic, assign) BOOL showList;
@property (nonatomic, assign) NSInteger catID;
@property (nonatomic, assign) CalendarEventListType activeEventList;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) MKMapView *mapView;

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSArray *events;

//@property (nonatomic, retain) DatePickerViewController *dateSelector;

- (void)abortExtraneousRequest;
- (void)makeRequest;
- (void)makeSearchRequest:(NSString *)searchTerms;

- (void)mapButtonToggled;
- (void)listButtonToggled;
- (void)sideButtonPressed:(id)sender;
- (void)buttonPressed:(id)sender;

- (void)reloadView:(CalendarEventListType)listType;
- (void)selectScrollerButton:(NSString *)buttonTitle;


@end

