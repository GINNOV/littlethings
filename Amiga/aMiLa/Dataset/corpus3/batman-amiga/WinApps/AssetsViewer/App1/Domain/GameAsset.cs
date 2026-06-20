using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace App1.Domain
{
    public class GameAsset
    {
        private Memory<byte> _memoryBuffer;

        public Memory<byte> MemoryBuffer { get { return _memoryBuffer; } }


        private GameAsset()
        { }


        private GameAsset(Memory<byte> memoryBuffer)
        {
            _memoryBuffer = memoryBuffer;
        }


        public async static Task<GameAsset> CreateGameAsset(Stream dataStream, CancellationToken token)
        {
            var bytes = new byte[dataStream.Length];
            var memory = new Memory<byte>(bytes);
            var result = await dataStream.ReadAsync(memory, token);

            GameAsset asset = new GameAsset(memory);
            return asset;
        }

    }

}
