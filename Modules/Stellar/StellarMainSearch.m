#import "StellarMainSearch.h"
#import "StellarClass.h"
#import "StellarDetailViewController.h"
#import "StellarMainTableController.h"
#import "StellarClassTableCell.h"
#import "UITableView+MITUIAdditions.h"
#import "MITUIConstants.h"
#import "MITSearchDisplayController.h"
#import "MultiLineTableViewCell.h"

@implementation StellarMainSearch

@synthesize lastResults;
@synthesize activeMode;

- (BOOL) isSearchResultsVisible {
	return hasSearchInitiated && activeMode;
}

- (id) initWithViewController: (StellarMainTableController *)controller{
	if(self = [super init]) {
		activeMode = NO;
		viewController = controller;
		self.lastResults = [NSArray array];
		hasSearchInitiated = NO;
		resultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 55.0, 320.0, 420.0) style: UITableViewStyleGrouped];
		resultsTableView.delegate = self;
		resultsTableView.dataSource = self;
		resultsTableView.backgroundColor = [UIColor whiteColor];
		//[resultsTableView applyStandardColors];
		
	}
	return self;
}

- (void) dealloc {
	[lastResults release];
	[super dealloc];
}

#pragma mark UITableViewDataSource methods

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
	return [groups count];//[lastResults count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MultiLineTableViewCell *cell = (MultiLineTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"StellarMainSearch"];
	if(cell == nil) {
		cell = [[[MultiLineTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"StellarMainSearch"] autorelease];
	}
	
	//StellarClass *stellarClass = [self.lastResults objectAtIndex:indexPath.row];
	//[StellarClassTableCell configureCell:cell withStellarClass:stellarClass];
	
	NSString *key = [[groups allKeys] objectAtIndex: indexPath.row];
	cell.textLabel.text =  [[groups valueForKey:key] description];//@"100";
	cell.detailTextLabel.text = key;//((StellarClass *)[self.lastResults objectAtIndex:indexPath.row]).school;

	return cell;
}

/*
- (CGFloat) tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
	return [StellarClassTableCell cellHeightForTableView:tableView class:[self.lastResults objectAtIndex:indexPath.row]];
}*/

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView {
	return 1;
}

- (NSString *) tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
	if([lastResults count]) {
		return [NSString stringWithFormat:@"%i found", [lastResults count]];
	}
	return nil;
}

- (UIView *) tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *headerTitle = nil;
	
	if([lastResults count]) {
		headerTitle = [NSString stringWithFormat:@"%i found", [lastResults count]];
		return [UITableView ungroupedSectionHeaderWithTitle:headerTitle];
	}
	return nil;
}

- (CGFloat)tableView: (UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return UNGROUPED_SECTION_HEADER_HEIGHT;
}

#pragma mark UITableViewDelegate methods

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[StellarDetailViewController 
	 launchClass:(StellarClass *)[self.lastResults objectAtIndex:indexPath.row]
	 viewController:viewController];
}

#pragma mark ClassesSearchDelegate methods

- (void) searchComplete: (NSArray *)classes searchTerms:searchTerms {
	if([viewController.searchController.searchBar.text isEqualToString:searchTerms]) {
		self.lastResults = classes;
		
		groups = [self uniqueCourseGroups];
		
		if ([classes count] > 0)
			viewController.searchController.searchResultsTableView = resultsTableView;
		
			[viewController.searchController.searchResultsTableView reloadData];
			[viewController hideLoadingView];
			[viewController showSearchResultsTable];
		
		// if exactly one result found forward user to that result
		if([classes count] == 1) {
			[StellarDetailViewController 
			 launchClass:(StellarClass *)[classes lastObject]
			 viewController: viewController];
		}
	}
}

- (void) handleCouldNotReachStellarWithSearchTerms: (NSString *)searchTerms {
	if([viewController.searchController.searchBar.text isEqualToString:searchTerms]) {
		[viewController hideLoadingView];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Connection Failed" 
							  message:@"Could not connect to Stellar to execute search, please try again later."
							  delegate:nil
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		
		[viewController.searchController.searchResultsTableView reloadData];
		
		[alert show];
		[alert release];
	}
}

- (void) handleTooManySearchResults {
	
	[viewController hideLoadingView];
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Narrow Search" 
						  message:@"Retrieved more than 100 results. Please refine your query"
						  delegate:nil
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	
	[viewController.searchController.searchResultsTableView reloadData];
	
	[alert show];
	[alert release];
}


-(NSMutableDictionary *) uniqueCourseGroups{
	//((StellarClass *)[self.lastResults objectAtIndex:indexPath.row]).school;
	
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
	
	for (int index=0; index < [self.lastResults count]; index++) {
		
		if (![tempArray containsObject:((StellarClass *)[self.lastResults objectAtIndex:index]).school]) {
			[tempArray addObject:((StellarClass *)[self.lastResults objectAtIndex:index]).school];
			NSNumber *count = [NSNumber numberWithInt:1];
			[tempDict setObject:count forKey:((StellarClass *)[self.lastResults objectAtIndex:index]).school];
		}
		
		else {
			NSNumber *lastCount = [tempDict objectForKey:((StellarClass *)[self.lastResults objectAtIndex:index]).school];
			
			NSNumber *count = [NSNumber numberWithInt:([lastCount intValue] +1 )];
			[tempDict removeObjectForKey:((StellarClass *)[self.lastResults objectAtIndex:index]).school];
			[tempDict setObject:count forKey:((StellarClass *)[self.lastResults objectAtIndex:index]).school];
		}

		
	}
	
	return tempDict;

	
}

@end