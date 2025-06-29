import Foundation
import Clibiff // Imports the C library target via the module map

/// A public struct that acts as a Swift-friendly wrapper around the C functions
/// from the Clibiff library.
public struct IFF {

    /// Reads an IFF file from a given path and returns a pointer to the parsed chunk structure.
    /// This directly calls the underlying C function `IFF_read`.
    /// - Parameter filePath: The path to the IFF file.
    /// - Returns: An UnsafeMutablePointer to an IFF_Chunk struct, or nil on failure.
    public static func read(filePath: String) -> UnsafeMutablePointer<IFF_Chunk>? {
        // The C function `IFF_read` requires two arguments: filename and chunkRegistry
        // Using nil for chunkRegistry will use the default registry
        return IFF_read(filePath, nil)
    }

    /// Frees the memory allocated by the IFF_read C function.
    /// It's crucial to call this to prevent memory leaks.
    /// - Parameter chunk: The pointer to the IFF_Chunk to be deallocated.
    public static func free(chunk: UnsafeMutablePointer<IFF_Chunk>) {
        // CORRECTED: The C function `IFF_free` requires two arguments.
        IFF_free(chunk, nil)
    }

    /// A helper function to find a specific sub-chunk within a FORM chunk.
    /// - Parameters:
    ///   - form: The form chunk to search within (must be a FORM chunk).
    ///   - chunkId: The 4-character identifier of the chunk to find (e.g., "BMHD").
    /// - Returns: A pointer to the found chunk, or nil if not found.
    public static func findChunk(in form: UnsafeMutablePointer<IFF_Form>, chunkId: IFF_ID) -> UnsafeMutablePointer<IFF_Chunk>? {
        // Use IFF_getChunkFromForm to find the chunk by ID
        return IFF_getChunkFromForm(form, chunkId)
    }
    
    /// A helper function to find a specific data chunk within a FORM chunk.
    /// - Parameters:
    ///   - form: The form chunk to search within (must be a FORM chunk).
    ///   - chunkId: The 4-character identifier of the chunk to find (e.g., "BMHD").
    /// - Returns: A pointer to the found chunk, or nil if not found.
    public static func findDataChunk(in form: UnsafeMutablePointer<IFF_Form>, chunkId: IFF_ID) -> UnsafeMutablePointer<IFF_Chunk>? {
        // Use IFF_getDataChunkFromForm to find the data chunk by ID
        return IFF_getDataChunkFromForm(form, chunkId)
    }
}
