//
//  ComplicationController.swift
//  HallonWatch Extension
//
//  Created by Paul Griffin on 19/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        print("Updating complication")
        HallonScraper(username: "paul.griffin@hotmail.com", password: "urxb72r4").getDataUsage{
            switch $0{
            case .Success(let hallonUsage):
                print("Sucess")
                let timelineEntry = self.getComplicationForUsage(hallonUsage, family: complication.family)
                if timelineEntry == nil,
                    let modularTemplate = self.getDefaultComplication(complication){
                        return handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate))
                }
                return handler(timelineEntry)
            case .Error(let error):
                print(error)
                if let modularTemplate = self.getDefaultComplication(complication){
                    return handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate))
                }
                handler(nil)
            }
            
        };
    }
    
    func getComplicationForUsage(hallonUsage: HallonScraper.HallonUsage, family: CLKComplicationFamily) -> CLKComplicationTimelineEntry?{

        let percent = Float(hallonUsage.dataUsed / hallonUsage.dataMax)
        var timelineEntry: CLKComplicationTimelineEntry
        switch family {
        case .CircularSmall:
            let modularTemplate = CLKComplicationTemplateCircularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: String(format: "%.1f", arguments: [hallonUsage.dataLeft]))
            modularTemplate.fillFraction = percent
            modularTemplate.ringStyle = .Closed
            timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate)
        case .ModularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallStackText()
            modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "Hallon")
            modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: String(format: "%.1f/%.1f", arguments: [hallonUsage.dataUsed,hallonUsage.dataMax]))
            timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate)
        case .UtilitarianSmall:
            let modularTemplate = CLKComplicationTemplateUtilitarianSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: String(format: "%.1f", arguments: [hallonUsage.dataLeft]))
            modularTemplate.fillFraction = percent
            modularTemplate.ringStyle = .Closed
            timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate)
        case .ModularLarge:
            let modularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularTemplate.headerImageProvider = CLKImageProvider(backgroundImage: UIImage(named: "HallonSmall")!, backgroundColor: nil)
            modularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Hallon")
            let str = String(format: "%.1f/%.1f GB", arguments: [hallonUsage.dataUsed,hallonUsage.dataMax])
            modularTemplate.body1TextProvider = CLKSimpleTextProvider(text: str, shortText: "")
            timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate)
        case .UtilitarianLarge:
            let modularTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            let str = String(format: "%.1f/%.1f GB", arguments: [hallonUsage.dataUsed,hallonUsage.dataMax])
            modularTemplate.textProvider = CLKSimpleTextProvider(text: str, shortText: "")
            timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: modularTemplate)
        }
        return timelineEntry
    }
    func getDefaultComplication(complication: CLKComplication) -> CLKComplicationTemplate?{
        let percent:Float = 0.7
        var template: CLKComplicationTemplate
        switch complication.family {
        case .CircularSmall:
            let modularTemplate = CLKComplicationTemplateCircularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "-.-")
            modularTemplate.fillFraction = percent
            modularTemplate.ringStyle = .Closed
            template = modularTemplate
        case .ModularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "-.-")
            modularTemplate.fillFraction = percent
            modularTemplate.ringStyle = .Closed
            template = modularTemplate
        case .UtilitarianSmall:
            let modularTemplate = CLKComplicationTemplateUtilitarianSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "-.-")
            modularTemplate.fillFraction = percent
            modularTemplate.ringStyle = .Closed
            template = modularTemplate
        case .ModularLarge:
            let modularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Hallon")
            modularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "_._/_._ GB", shortText: "")
            template = modularTemplate
        case .UtilitarianLarge:
            let modularTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "_._/_._ GB", shortText: "")
            template = modularTemplate
        }
        return template
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(NSDate(timeIntervalSinceNow: 60*60) as! NSDate);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(getDefaultComplication(complication))
    }
    
}
