import { NativeModules, Platform } from 'react-native'
import type { Spec } from './specs/NativeRNDocumentPicker'

const LINKING_ERROR = 'The package \'react-native-document-picker-macos\' doesn\'t seem to be linked. Make sure: \n\n'
    + '- You have run \'pod install\'\n'
    + '- You rebuilt the app after installing the package\n'
    + '- You are not using Expo Go\n'

const PLATFORM_ERROR = 'The package \'react-native-document-picker-macos\' only works on macOS'

const RNDocumentPicker: Spec = Platform.select({
    macos: NativeModules.RNDocumentPicker ?? new Proxy({}, {
        get() {
            throw new Error(LINKING_ERROR)
        },
    }),
    default: new Proxy({}, {
        get() {
            throw new Error(PLATFORM_ERROR)
        },
    }),
})

export interface PickerOptions {
    /**
     * Whether multiple items can be selected
     *
     * @default false
     */
    multiple?: boolean
    /**
     * An array of Uniform Type Identifiers (UTIs) limiting the allowed content types
     * If not provided, any type is allowed
     *
     * @example ['public.image', 'public.video']
     * @see https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
     */
    allowedUTIs?: string[]
}

export interface File {
    /** Absolute file path on disk */
    path: string
    /** File URI (file://) */
    uri: string
    /** Last path component */
    name: string
    /** File size in bytes */
    size: number | null
    /** Mime-type @example 'image/jpeg' */
    mimeType: string | null
}

export interface Directory {
    /** Absolute directory path on disk */
    path: string
    /** File URI (file://) */
    uri: string
    /** Last path component */
    name: string
    /** Directory size in bytes */
    size: number | null
}

/**
 * Presents the native macOS file picker
 * Resolves with an array of results; at most 1 element if `multiple` is false, or none if the user canceled the dialog
 */
export async function pickFile(options?: PickerOptions): Promise<File[]> {
    return RNDocumentPicker.pick({
        ...options,
        allowFileSelection: true,
        allowDirectorySelection: false,
    }).catch(handleError)
}

/**
 * Presents the native macOS directory picker
 * Resolves with an array of results; at most 1 element if `multiple` is false, or none if the user canceled the dialog
 */
export async function pickDirectory(options?: PickerOptions): Promise<Directory[]> {
    return RNDocumentPicker.pick({
        ...options,
        allowDirectorySelection: true,
        allowFileSelection: false,
    }).catch(handleError)
}

function handleError(error: unknown) {
    if (error instanceof Error && 'code' in error && error.code === 'USER_CANCELLED') {
        return []
    }
    throw error
}
