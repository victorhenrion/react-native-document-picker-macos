import { Button, StyleSheet, Switch, Text, TextInput, View } from 'react-native'
import { type Directory, type File, pickDirectory, pickFile } from 'react-native-document-picker-macos'
import React from 'react'

export default function App() {
    const [result, setResult] = React.useState<File[] | Directory[]>([])

    const [multiple, setMultiple] = React.useState(false)

    const [utisText, setUtisText] = React.useState('')
    const allowedUTIs = utisText.split(',').map((utis) => utis.trim())

    return (
        <View style={styles.container}>
            {/* Multiple toggle */}
            <View style={styles.row}>
                <Text style={styles.label}>Multiple</Text>
                <Switch
                    value={multiple}
                    onValueChange={setMultiple}
                />
            </View>
            {/* Allowed UTIs */}
            <View style={styles.row}>
                <Text style={styles.label}>Allowed UTIs</Text>
                <TextInput
                    value={utisText}
                    onChangeText={setUtisText}
                    placeholder="Comma-separated list"
                    style={styles.input}
                />
            </View>

            <View style={styles.separator} />

            {/* Pickers */}
            <View style={styles.row}>
                <Button
                    title="Pick File"
                    onPress={() => pickFile({ multiple, allowedUTIs }).then(setResult)}
                />
                <Button
                    title="Pick Directory"
                    onPress={() => pickDirectory({ multiple, allowedUTIs }).then(setResult)}
                />
            </View>

            <View style={styles.separator} />

            {/* Result */}
            <View style={styles.row}>
                <Text style={styles.label}>Result</Text>
                <Text>{JSON.stringify(result, null, 2)}</Text>
            </View>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        margin: 'auto',
    },
    row: {
        minHeight: 50,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 10,
    },
    label: {
        fontSize: 16,
        width: 100,
        textAlign: 'right',
    },
    input: {
        backgroundColor: 'white',
        width: 150,
    },
    separator: {
        height: 1,
        backgroundColor: 'black',
        marginVertical: 15,
    },
    button: {
        marginTop: 10,
    },
})
