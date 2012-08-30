using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace PrepWebLog
{
	class Program
	{
		static int Main(string[] args)
		{
			if (args.Length < 2)
			{
				Console.Write("Usage: PrepWebLog.exe [InputFile] [OutputFile]\n");
				return -1;
			}

			try
			{
				string path = args[0];
				using (FileStream sourceFile = File.OpenRead(args[0]), destinationFile = File.Create(args[1]))
				using (StreamReader sourceFileReader = new StreamReader(sourceFile))
				using (StreamWriter destinationFileWriter = new StreamWriter(destinationFile))
				{
					string line;
					while ((line = sourceFileReader.ReadLine()) != null)
					{
						// remove any lines that start with #
						if (line[0] != '#')
							destinationFileWriter.WriteLine(line);
					}
					destinationFileWriter.Close();
					sourceFileReader.Close();
					destinationFile.Close();
					sourceFile.Close();
				}
			}
			catch (Exception e)
			{
				Console.Write(string.Format("Could not process the file. Error: {0}\nStack Trace: {1}", e.Message, e.StackTrace));
				return -1;
			}
			return 0;
		}
	}
}
