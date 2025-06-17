import type { TurboModule } from 'react-native'
import { TurboModuleRegistry } from 'react-native'

export interface Spec extends TurboModule {
    pick(options: {
        allowDirectorySelection?: boolean
        allowFileSelection?: boolean
        multiple?: boolean
        allowedUTIs?: string[]
    }): Promise<
        Array<{
            uri: string
            path: string
            name: string
            size: number | null
            mimeType: string | null
        }>
    >
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNDocumentPicker')
