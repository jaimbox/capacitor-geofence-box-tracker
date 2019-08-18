declare global {
    interface PluginRegistry {
        GeofenceTracker: GeofenceTrackerPlugin;
    }
}
export interface GeofenceTrackerPlugin {
    setup(options: {
        notifyOnEntry: boolean;
        notifyOnExit: boolean;
    }): Promise<{
        value: string;
    }>;
    addRegion(options: {
        latitude: number;
        longitude: number;
        radius?: number;
        identifier: string;
    }): Promise<{
        value: string;
    }>;
    stopMonitoring(options: {
        identifier: string;
    }): Promise<{
        value: string;
    }>;
    monitoredRegions(): Promise<{
        value: string;
    }>;
    registerForPushNotifications(): Promise<{
        value: string;
    }>;
}
