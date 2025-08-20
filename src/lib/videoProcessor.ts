import { FFmpeg } from '@ffmpeg/ffmpeg';
import { fetchFile, toBlobURL } from '@ffmpeg/util';

const ffmpeg = new FFmpeg();
let ffmpegLoaded = false;

export interface ExportSettings {
  frameRate: number;
  resolution: string;
  quality: string;
  keyframeInterval: number;
  opticalSmoothing: boolean;
  codec: string;
  bitrate: string;
}

export interface VideoProcessingOptions {
  compressForEditing?: boolean;
  targetResolution?: string;
  targetBitrate?: string;
}

export interface VideoAnalysis {
  duration: number;
  fps: number;
  resolution: { width: number; height: number };
  bitrate: number;
  scenes: number[];
  audioChannels: number;
  hasAudio: boolean;
}

export const loadFFmpeg = async () => {
  if (!ffmpegLoaded) {
    const baseURL = 'https://unpkg.com/@ffmpeg/core@0.12.2/dist/umd';
    ffmpeg.on('log', ({ message }) => {
      console.log(message);
    });
    
    await ffmpeg.load({
      coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
      wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm'),
    });
    
    ffmpegLoaded = true;
  }
};

// Compress video to 1080p for smoother editing (CapCut/Premiere Pro style)
export const compressVideoForEditing = async (
  file: File, 
  onProgress?: (progress: number) => void
): Promise<Blob> => {
  try {
    await loadFFmpeg();
    
    const inputName = 'input.mp4';
    const outputName = 'compressed.mp4';
    
    await ffmpeg.writeFile(inputName, await fetchFile(file));
    
    // Compress to 1080p with optimized settings for editing
    const args = [
      '-i', inputName,
      '-vf', 'scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2',
      '-c:v', 'libx264',
      '-preset', 'fast',
      '-crf', '23',
      '-c:a', 'aac',
      '-b:a', '128k',
      '-movflags', '+faststart',
      outputName
    ];
    
    // Set up progress tracking
    ffmpeg.on('progress', ({ progress }: { progress: number }) => {
      if (onProgress) {
        onProgress(Math.round(progress * 100));
      }
    });
    
    await ffmpeg.exec(args);
    
    const data = await ffmpeg.readFile(outputName);
    return new Blob([data], { type: 'video/mp4' });
    
  } catch (error) {
    console.error('Video compression error:', error);
    throw error;
  }
};

// Advanced video processing with all professional features
export const processVideo = async (
  file: File, 
  settings: ExportSettings,
  onProgress?: (progress: number) => void
): Promise<Blob> => {
  try {
    await loadFFmpeg();
    
    const inputName = 'input.mp4';
    const outputName = 'output.mp4';
    
    await ffmpeg.writeFile(inputName, await fetchFile(file));
    
    // Build comprehensive FFmpeg command
    const args = [
      '-i', inputName,
      '-c:v', getVideoCodec(settings.codec),
      '-r', settings.frameRate.toString(),
      '-s', getResolution(settings.resolution),
      '-b:v', getBitrate(settings.bitrate, settings.resolution),
      '-keyint_min', settings.keyframeInterval.toString(),
      '-g', (settings.keyframeInterval * settings.frameRate).toString()
    ];

    // Add optical flow smoothing (DaVinci Resolve style)
    if (settings.opticalSmoothing) {
      args.push('-vf', `minterpolate=fps=${settings.frameRate}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1`);
    }

    // Add quality settings based on codec
    args.push(...getQualitySettings(settings.quality, settings.codec));
    
    // Audio processing
    args.push('-c:a', 'aac', '-b:a', '192k');
    
    // Optimization flags
    args.push('-movflags', '+faststart');
    
    args.push(outputName);
    
    // Set up progress tracking
    ffmpeg.on('progress', ({ progress }: { progress: number }) => {
      if (onProgress) {
        onProgress(Math.round(progress * 100));
      }
    });
    
    await ffmpeg.exec(args);
    
    const data = await ffmpeg.readFile(outputName);
    return new Blob([data], { type: 'video/mp4' });
    
  } catch (error) {
    console.error('Video processing error:', error);
    throw error;
  }
};

// Extract frames for thumbnail generation (Premiere Pro style)
export const extractFrames = async (file: File, count: number = 10): Promise<Blob[]> => {
  try {
    await loadFFmpeg();
    
    await ffmpeg.writeFile('input.mp4', await fetchFile(file));
    
    // Extract frames at regular intervals
    await ffmpeg.exec([
      '-i', 'input.mp4',
      '-vf', `select=not(mod(n\\,${Math.floor(30/count)}))`,
      '-vsync', 'vfr',
      '-q:v', '2',
      'frame_%03d.jpg'
    ]);
    
    const frames = [];
    for (let i = 1; i <= count; i++) {
      try {
        const frameData = await ffmpeg.readFile(`frame_${i.toString().padStart(3, '0')}.jpg`);
        frames.push(new Blob([frameData], { type: 'image/jpeg' }));
      } catch (e) {
        break; // No more frames
      }
    }
    
    return frames;
  } catch (error) {
    console.error('Frame extraction error:', error);
    throw error;
  }
};

// Video analysis for AI features (DaVinci Resolve style)
export const analyzeVideo = async (file: File): Promise<VideoAnalysis> => {
  try {
    await loadFFmpeg();
    
    await ffmpeg.writeFile('input.mp4', await fetchFile(file));
    
    // Get video info
    await ffmpeg.exec(['-i', 'input.mp4', '-f', 'null', '-']);
    
    // Scene detection
    await ffmpeg.exec([
      '-i', 'input.mp4',
      '-vf', 'select=gt(scene\\,0.3)',
      '-vsync', 'vfr',
      '-f', 'null', '-'
    ]);
    
    // Mock analysis results (in real implementation, parse FFmpeg output)
    return {
      duration: 120, // seconds
      fps: 30,
      resolution: { width: 1920, height: 1080 },
      bitrate: 8000, // kbps
      scenes: [0, 15, 45, 78, 105], // scene change timestamps
      audioChannels: 2,
      hasAudio: true
    };
    
  } catch (error) {
    console.error('Video analysis error:', error);
    throw error;
  }
};

// Apply video effects (CapCut/Premiere Pro style)
export const applyVideoEffect = async (
  file: File,
  effect: string,
  parameters: { [key: string]: any }
): Promise<Blob> => {
  try {
    await loadFFmpeg();
    
    await ffmpeg.writeFile('input.mp4', await fetchFile(file));
    
    let filterString = '';
    
    switch (effect) {
      case 'speed-ramp':
        filterString = `setpts=${1/parameters.speed}*PTS`;
        break;
      case 'stabilization':
        filterString = 'vidstabdetect=shakiness=10:accuracy=10:result=transforms.trf,vidstabtransform=input=transforms.trf:zoom=0:smoothing=10';
        break;
      case 'color-correction':
        filterString = `eq=contrast=${parameters.contrast}:brightness=${parameters.brightness}:saturation=${parameters.saturation}`;
        break;
      case 'blur':
        filterString = `gblur=sigma=${parameters.intensity}`;
        break;
      case 'sharpen':
        filterString = `unsharp=5:5:${parameters.intensity}:5:5:0.0`;
        break;
      case 'chromakey':
        filterString = `chromakey=0x${parameters.color}:${parameters.similarity}:${parameters.blend}`;
        break;
      case 'lut':
        filterString = `lut3d=${parameters.lutFile}`;
        break;
      default:
        filterString = 'null';
    }
    
    await ffmpeg.exec([
      '-i', 'input.mp4',
      '-vf', filterString,
      '-c:a', 'copy',
      'output.mp4'
    ]);
    
    const data = await ffmpeg.readFile('output.mp4');
    return new Blob([data], { type: 'video/mp4' });
    
  } catch (error) {
    console.error('Effect application error:', error);
    throw error;
  }
};

// Audio processing functions (Premiere Pro/DaVinci style)
export const processAudio = async (
  file: File,
  settings: {
    volume: number;
    eq: { low: number; mid: number; high: number };
    compressor: { threshold: number; ratio: number };
    noiseReduction: boolean;
  }
): Promise<Blob> => {
  try {
    await loadFFmpeg();
    
    await ffmpeg.writeFile('input.mp4', await fetchFile(file));
    
    let audioFilters = [];
    
    // Volume adjustment
    if (settings.volume !== 100) {
      audioFilters.push(`volume=${settings.volume/100}`);
    }
    
    // EQ
    if (settings.eq.low !== 0 || settings.eq.mid !== 0 || settings.eq.high !== 0) {
      audioFilters.push(`equalizer=f=100:width_type=h:width=50:g=${settings.eq.low}`);
      audioFilters.push(`equalizer=f=1000:width_type=h:width=100:g=${settings.eq.mid}`);
      audioFilters.push(`equalizer=f=10000:width_type=h:width=1000:g=${settings.eq.high}`);
    }
    
    // Compressor
    if (settings.compressor.threshold < 0) {
      audioFilters.push(`acompressor=threshold=${settings.compressor.threshold}dB:ratio=${settings.compressor.ratio}:attack=5:release=50`);
    }
    
    // Noise reduction
    if (settings.noiseReduction) {
      audioFilters.push('afftdn=nf=-25');
    }
    
    const audioFilterString = audioFilters.length > 0 ? audioFilters.join(',') : 'anull';
    
    await ffmpeg.exec([
      '-i', 'input.mp4',
      '-af', audioFilterString,
      '-c:v', 'copy',
      'output.mp4'
    ]);
    
    const data = await ffmpeg.readFile('output.mp4');
    return new Blob([data], { type: 'video/mp4' });
    
  } catch (error) {
    console.error('Audio processing error:', error);
    throw error;
  }
};

// Helper functions
const getVideoCodec = (codec: string): string => {
  const codecMap: { [key: string]: string } = {
    'H.264': 'libx264',
    'H.265': 'libx265',
    'VP9': 'libvpx-vp9',
    'AV1': 'libaom-av1',
    'ProRes': 'prores_ks'
  };
  return codecMap[codec] || 'libx264';
};

const getResolution = (resolution: string): string => {
  const resolutionMap: { [key: string]: string } = {
    '480p': '854x480',
    '720p': '1280x720',
    '1080p': '1920x1080',
    '1440p': '2560x1440',
    '2160p': '3840x2160',
    '4320p': '7680x4320'
  };
  return resolutionMap[resolution] || '1920x1080';
};

const getBitrate = (bitrate: string, resolution: string): string => {
  if (bitrate !== 'Auto') {
    return bitrate + 'M';
  }
  
  // Auto bitrate based on resolution (optimized for quality)
  const autoBitrates: { [key: string]: string } = {
    '480p': '2M',
    '720p': '5M',
    '1080p': '8M',
    '1440p': '16M',
    '2160p': '45M',
    '4320p': '100M'
  };
  return autoBitrates[resolution] || '8M';
};

const getQualitySettings = (quality: string, codec: string): string[] => {
  const settings: string[] = [];
  
  if (codec === 'H.264' || codec === 'libx264') {
    switch (quality) {
      case 'Draft':
        settings.push('-preset', 'ultrafast', '-crf', '28');
        break;
      case 'Low':
        settings.push('-preset', 'fast', '-crf', '26');
        break;
      case 'Medium':
        settings.push('-preset', 'medium', '-crf', '23');
        break;
      case 'High':
        settings.push('-preset', 'slow', '-crf', '20');
        break;
      case 'Ultra':
        settings.push('-preset', 'veryslow', '-crf', '18');
        break;
      case 'Lossless':
        settings.push('-preset', 'veryslow', '-crf', '0');
        break;
    }
  }
  
  return settings;
};

// Advanced features from professional editors
export const createProxyMedia = async (file: File): Promise<Blob> => {
  // Create low-resolution proxy for smooth editing (Premiere Pro feature)
  return compressVideoForEditing(file);
};

export const generateWaveform = async (file: File): Promise<number[]> => {
  // Generate audio waveform data for timeline display
  try {
    await loadFFmpeg();
    
    await ffmpeg.writeFile('input.mp4', await fetchFile(file));
    
    // Extract audio and generate waveform data
    await ffmpeg.exec([
      '-i', 'input.mp4',
      '-ac', '1',
      '-ar', '8000',
      '-f', 'f32le',
      'audio.raw'
    ]);
    
    const audioData = await ffmpeg.readFile('audio.raw');
    const samples = new Float32Array(audioData as ArrayBuffer);
    
    // Downsample for waveform visualization
    const waveformData = [];
    const step = Math.floor(samples.length / 1000); // 1000 points for waveform
    
    for (let i = 0; i < samples.length; i += step) {
      let sum = 0;
      for (let j = 0; j < step && i + j < samples.length; j++) {
        sum += Math.abs(samples[i + j]);
      }
      waveformData.push(sum / step);
    }
    
    return waveformData;
  } catch (error) {
    console.error('Waveform generation error:', error);
    return [];
  }
};
