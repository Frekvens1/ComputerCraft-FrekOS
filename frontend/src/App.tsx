import './App.css'
import {DevicesPage} from '@/pages/devices/DevicesPage.tsx';


function App() {
    return (
        <main className='h-svh flex flex-col'>
            <div className='flex-1 flex flex-col gap-2 items-center justify-center'>

                <DevicesPage/>

            </div>
        </main>
    )
}

export default App
