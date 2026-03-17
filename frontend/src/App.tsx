import './App.css'
import {DevicesPage} from '@/pages/devices/DevicesPage.tsx';


function App() {
    return (
        <main className='h-screen md:h-dvh flex flex-col'>
            <div className='h-full flex flex-col gap-2 items-center justify-center'>

                <DevicesPage/>

            </div>
        </main>
    )
}

export default App
